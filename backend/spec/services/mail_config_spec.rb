# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MailConfig do
  let(:service) { described_class.new }

  RSpec.shared_context 'when the smtp_settings file is present' do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/run/secrets/smtp_settings.json').and_return(true)

      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with('/run/secrets/smtp_settings.json').and_return(
        File.read('spec/fixtures/smtp/settings.json')
      )
    end
  end

  RSpec.shared_context 'when the SMTP settings are provided in various sparate files' do
    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with('/run/secrets/smtp_address').and_return("mail.example.com\n")
      allow(File).to receive(:read).with('/run/secrets/smtp_port').and_return("465\n")
      allow(File).to receive(:read).with('/run/secrets/smtp_user_name').and_return("foo@bar.com\n")
      allow(File).to receive(:read).with('/run/secrets/smtp_password').and_return("mysmtppassword\n")
      allow(File).to receive(:read).with('/run/secrets/smtp_authentication').and_return("login \n")
    end
  end

  describe '#smtp_settings' do
    before do
      allow(File).to receive(:exist?).and_return(false)
    end

    RSpec.shared_examples 'returns valid SMTP settings' do
      it do
        expect(service.smtp_settings).to eq(
          address: 'mail.example.com',
          port: 465,
          user_name: 'foo@bar.com',
          password: 'mysmtppassword',
          authentication: 'login',
          tls: true
        )
      end
    end

    context 'when the smtp_settings file is present' do
      include_context 'when the smtp_settings file is present'
      it_behaves_like 'returns valid SMTP settings'
    end

    context 'when the SMTP settings are provided in various sparate files' do
      include_context 'when the SMTP settings are provided in various sparate files'
      it_behaves_like 'returns valid SMTP settings'

      context 'when any of the files is missing' do
        before do
          allow(File).to receive(:read).with('/run/secrets/smtp_authentication').and_raise(Errno::ENOENT)
        end

        it { expect(service.smtp_settings).to eq({}) }
      end
    end
  end

  describe '#default_from' do
    context 'when the smtp_settings file is present' do
      include_context 'when the smtp_settings file is present'

      it 'returns the content from the user_name key of the file smtp_settings.json' do
        expect(service.default_from).to eq('foo@bar.com')
      end
    end

    context 'when the SMTP settings are provided in various sparate files' do
      include_context 'when the SMTP settings are provided in various sparate files'

      it 'returns the content of the file smtp_user_name' do
        expect(service.default_from).to eq('foo@bar.com')
      end
    end

    context 'when the files are not configured' do
      it { expect(service.default_from).to eq('development@example.com') }
    end
  end
end
