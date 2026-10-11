# frozen_string_literal: true

class PlannerDocumentsController < ApplicationController
  before_action :reject_service_tokens
  before_action :find_record

  rescue_from ActiveRecord::StaleObjectError do
    render json: { message: 'This record changed. Refresh its documents and try again.' }, status: :conflict
  end
  rescue_from ActiveRecord::RecordInvalid do |error|
    render json: { message: error.record.errors.full_messages.join(' ') }, status: :unprocessable_content
  end

  def create
    file = params[:file]
    unless file.is_a?(ActionDispatch::Http::UploadedFile) && file.size.positive? && file.size <= PlannerDocument::MAX_FILE_BYTES
      return render json: { message: 'Choose a file between 1 byte and 3 MB.' }, status: :unprocessable_content
    end

    PlannerDocument.transaction do
      # A wedding lock serializes quota checks across records and collaborators.
      ActsAsTenant.current_tenant.lock!
      @record.lock!
      require_version!
      if @record.documents.count >= PlannerDocument::MAX_RECORD_FILES
        return render json: { message: 'This record already has 10 documents. Remove one before uploading another.' }, status: :unprocessable_content
      end
      if PlannerDocument.sum(:byte_size) + file.size > PlannerDocument::MAX_WEDDING_BYTES
        return render json: { message: 'Wedding document storage is full (100 MB). Remove files to make space.' }, status: :unprocessable_content
      end
      filename = File.basename(file.original_filename.to_s.tr('\\', '/')).gsub(/[[:cntrl:]]/, '').strip
      @record.documents.create!(
        file_name: filename, content_type: PlannerDocument::TYPES[File.extname(filename).downcase],
        byte_size: file.size, data: file.read(PlannerDocument::MAX_FILE_BYTES + 1), uploaded_by: current_user
      )
      @record.touch
    end
    render json: result, status: :created
  end

  def show
    document = @record.documents.find(params[:id])
    response.headers['Cache-Control'] = 'private, no-store'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    # Force a download, even for HTML-like text or active Office content.
    send_data document.data, filename: document.file_name, type: 'application/octet-stream', disposition: 'attachment'
  end

  def destroy
    PlannerDocument.transaction do
      ActsAsTenant.current_tenant.lock!
      @record.lock!
      require_version!
      @record.documents.find(params[:id]).destroy!
      @record.touch
    end
    render json: result
  end

  private

  def reject_service_tokens
    head :forbidden if oauth?
  end

  def find_record
    model = { 'tasks' => Task, 'vendors' => PlannerVendor }.fetch(params[:entity])
    @record = model.find(params[:record_id])
  end

  def require_version!
    version = Integer(params[:lock_version].to_s, exception: false)
    raise ActionController::ParameterMissing, :lock_version unless version
    raise ActiveRecord::StaleObjectError.new(@record, 'update') unless @record.lock_version == version
  end

  def result
    { record_id: @record.id, lock_version: @record.lock_version,
      documents: @record.documents.select(*PlannerDocument::METADATA_FIELDS).order(created_at: :asc).map(&:metadata) }
  end
end
