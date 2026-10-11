# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Together planner', type: :request do
  let(:wedding) { create(:wedding) }
  around { |example| ActsAsTenant.with_tenant(wedding) { example.run } }
  let(:user) { create(:user, wedding:) }
  let(:headers) { { 'Accept' => 'application/json' } }

  before { sign_in user }

  def under_wedding(&block)
    ActsAsTenant.with_tenant(wedding, &block)
  end

  it 'rejects a signed-in person outside the wedding' do
    other_wedding = create(:wedding)
    get "/#{other_wedding.slug}/planner", headers: headers
    expect(response).to have_http_status(:forbidden)
  end

  it 'does not expose records from a different wedding' do
    other_wedding = create(:wedding)
    ActsAsTenant.with_tenant(other_wedding) { Task.create!(title: 'Private task') }
    get "/#{wedding.slug}/planner", headers: headers
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['tasks']).to eq([])
  end

  it 'rejects a stale edit rather than overwriting a collaborator' do
    task = under_wedding { Task.create!(title: 'Original') }
    under_wedding { task.update!(title: 'Edited by partner') }
    patch "/#{wedding.slug}/planner/tasks/#{task.id}",
          params: { record: { title: 'My stale edit' }, lock_version: 0 }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(under_wedding { task.reload.title }).to eq('Edited by partner')
  end

  it 'rejects attaching a task to another wedding event' do
    other_wedding = create(:wedding)
    event = ActsAsTenant.with_tenant(other_wedding) { WeddingEvent.create!(name: 'Private reception', date: '2027-02-20') }
    post "/#{wedding.slug}/planner/tasks",
         params: { record: { title: 'Test task', wedding_event_id: event.id } }, as: :json
    expect(response).to have_http_status(:not_found)
    expect(under_wedding { Task.count }).to eq(0)
  end

  it 'keeps guest attendance independent for each celebration' do
    events = under_wedding do
      [WeddingEvent.create!(name: 'Mehendi', date: '2027-02-19'), WeddingEvent.create!(name: 'Wedding', date: '2027-02-20')]
    end
    post "/#{wedding.slug}/planner/guests", params: {
      record: { name: 'Test guest', status: 'invited' },
      attendances: { events[0].id => 'confirmed', events[1].id => 'declined' }
    }, as: :json
    expect(response).to have_http_status(:created)
    guest = response.parsed_body['guests'].first
    expect(guest['attendances']).to include(events[0].id => 'confirmed', events[1].id => 'declined')
    expect(guest['status']).to eq('invited')
  end

  it 'rolls back the guest if an attendance references a different wedding' do
    other_wedding = create(:wedding)
    event = ActsAsTenant.with_tenant(other_wedding) { WeddingEvent.create!(name: 'Other event', date: '2027-02-20') }
    post "/#{wedding.slug}/planner/guests", params: {
      record: { name: 'Test guest', status: 'invited' }, attendances: { event.id => 'confirmed' }
    }, as: :json
    expect(response).to have_http_status(:not_found)
    expect(under_wedding { Guest.count }).to eq(0)
  end

  it 'updates and removes hosted guests without requiring a seating worker or Redis' do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('TOGETHER_HOSTED').and_return('true')
    expect(WeddingPlanner).not_to receive(:redis)
    post "/#{wedding.slug}/planner/guests", params: { record: { name: 'Hosted guest', status: 'confirmed' } }, as: :json
    expect(response).to have_http_status(:created)
    guest = response.parsed_body['guests'].first
    delete "/#{wedding.slug}/planner/guests/#{guest['id']}", params: { lock_version: guest['lock_version'] }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['guests']).to eq([])
  end
end

RSpec.describe 'Private planner documents', type: :request do
  let(:wedding) { create(:wedding) }
  around { |example| ActsAsTenant.with_tenant(wedding) { example.run } }
  let(:user) { create(:user, wedding:) }
  let(:task) { Task.create!(title: 'Review contract') }
  let(:vendor) { PlannerVendor.create!(name: 'Wedding venue', status: 'Booked') }
  let(:pdf) { "%PDF-1.4\n1 0 obj << /Type /Catalog >> endobj\n%%EOF\n".b }
  let(:headers) { { 'Accept' => 'application/json' } }

  before { sign_in user }

  def upload_bytes(bytes, filename = 'contract.pdf')
    Rack::Test::UploadedFile.new(StringIO.new(bytes), 'application/octet-stream', original_filename: filename)
  end

  def path_for(record)
    entity = record.is_a?(Task) ? 'tasks' : 'vendors'
    "/#{wedding.slug}/planner/#{entity}/#{record.id}/documents"
  end

  def attach(record, bytes = pdf, filename = 'contract.pdf', version = record.reload.lock_version)
    post path_for(record), params: { file: upload_bytes(bytes, filename), lock_version: version }, headers: headers
  end

  %i[task vendor].each do |kind|
    it "uploads, privately downloads, and removes a #{kind} document" do
      record = public_send(kind)
      attach(record)
      expect(response).to have_http_status(:created)
      metadata = response.parsed_body.fetch('documents').first
      expect(metadata).to include('file_name' => 'contract.pdf', 'byte_size' => pdf.bytesize)
      expect(metadata).not_to have_key('data')
      document_id = metadata.fetch('id')
      version = response.parsed_body.fetch('lock_version')
      get "#{path_for(record)}/#{document_id}", headers: headers
      expect(response.body.b).to eq(pdf)
      expect(response.headers['Content-Disposition']).to start_with('attachment;')
      expect(response.headers['Content-Type']).to start_with('application/octet-stream')
      expect(response.headers['Cache-Control']).to include('no-store')
      expect(response.headers['X-Content-Type-Options']).to eq('nosniff')
      get "/#{wedding.slug}/planner", headers: headers
      item = response.parsed_body.fetch(kind == :task ? 'tasks' : 'vendors').first
      expect(item.fetch('documents').first.fetch('id')).to eq(document_id)
      expect(response.body).not_to include('%PDF')
      delete "#{path_for(record)}/#{document_id}", params: { lock_version: version }, as: :json
      expect(response).to have_http_status(:ok)
      expect(record.documents.count).to eq(0)
    end

    it "removes stored files when their #{kind} is removed" do
      record = public_send(kind)
      attach(record)
      expect(response).to have_http_status(:created)
      record.reload.destroy!
      expect(PlannerDocument.count).to eq(0)
    end
  end

  it 'rejects another wedding and a document belonging to another record' do
    attach(task)
    id = response.parsed_body.fetch('documents').first.fetch('id')
    other_task = Task.create!(title: 'Other task')
    get "#{path_for(other_task)}/#{id}", headers: headers
    expect(response).to have_http_status(:not_found)
    other_wedding = create(:wedding)
    get "/#{other_wedding.slug}/planner/tasks/#{task.id}/documents/#{id}", headers: headers
    expect(response).to have_http_status(:forbidden)
  end

  it 'rejects an anonymous download even with the exact document address' do
    attach(vendor)
    id = response.parsed_body.fetch('documents').first.fetch('id')
    sign_out user
    get "#{path_for(vendor)}/#{id}", headers: headers
    expect(response).to have_http_status(:unauthorized)
    expect(response.body).not_to include('%PDF')
  end

  it 'rejects stale uploads and removals instead of overwriting collaborator changes' do
    attach(task)
    id = response.parsed_body.fetch('documents').first.fetch('id')
    version = response.parsed_body.fetch('lock_version')
    task.reload.update!(title: 'Partner updated this task')
    attach(task, pdf, 'second.pdf', version)
    expect(response).to have_http_status(:conflict)
    delete "#{path_for(task)}/#{id}", params: { lock_version: version }, as: :json
    expect(response).to have_http_status(:conflict)
    expect(task.documents.count).to eq(1)
  end

  it 'rejects empty, oversized, unsupported and disguised documents' do
    [['', 'empty.txt'], ['x' * (PlannerDocument::MAX_FILE_BYTES + 1), 'large.txt'],
     ['<script>alert(1)</script>', 'page.html'], ['This is not a PDF', 'fake.pdf'],
     ['Not a ZIP archive', 'fake.docx']].each do |bytes, filename|
      attach(task, bytes, filename)
      expect(response).to have_http_status(:unprocessable_content), filename
    end
    expect(task.documents.count).to eq(0)
  end

  it 'accepts Office documents and preserves Unicode filenames' do
    office = Zip::OutputStream.write_buffer do |archive|
      archive.put_next_entry('[Content_Types].xml')
      archive.write('<Types/>')
      archive.put_next_entry('word/document.xml')
      archive.write('<document/>')
    end.string
    attach(vendor, office, 'शादी-contract.docx')
    expect(response).to have_http_status(:created)
    expect(response.parsed_body['documents'].first['file_name']).to eq('शादी-contract.docx')
  end

  it 'enforces per-record count and shared wedding storage across tasks and vendors' do
    stub_const('PlannerDocument::MAX_RECORD_FILES', 1)
    stub_const('PlannerDocument::MAX_WEDDING_BYTES', pdf.bytesize + 1)
    attach(task)
    expect(response).to have_http_status(:created)
    attach(task, pdf, 'second.pdf')
    expect(response).to have_http_status(:unprocessable_content)
    attach(vendor)
    expect(response).to have_http_status(:unprocessable_content)
    expect(PlannerDocument.count).to eq(1)
  end

  it 'requires a CSRF token for uploads when forgery protection is enabled' do
    allow_any_instance_of(PlannerDocumentsController).to receive(:development_swagger?).and_return(false)
    allow_any_instance_of(PlannerDocumentsController).to receive(:protect_against_forgery?).and_return(true)
    attach(task)
    expect(response).to have_http_status(:unprocessable_content)
    expect(PlannerDocument.count).to eq(0)
  end
end
