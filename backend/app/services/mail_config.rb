# frozen_string_literal: true

class MailConfig
  def smtp_settings
    @smtp_settings ||= begin
      if File.exist?('/run/secrets/smtp_settings.json')
        JSON.parse(File.read('/run/secrets/smtp_settings.json')).symbolize_keys!
      else
        {
          address: File.read('/run/secrets/smtp_address').strip,
          port: File.read('/run/secrets/smtp_port').strip.to_i,
          user_name: File.read('/run/secrets/smtp_user_name').strip,
          password: File.read('/run/secrets/smtp_password').strip,
          authentication: File.read('/run/secrets/smtp_authentication').strip,
          tls: true
        }
      end
    rescue Errno::ENOENT
      {}
    end
  end

  def default_from
    smtp_settings[:user_name] || 'development@example.com'
  end
end
