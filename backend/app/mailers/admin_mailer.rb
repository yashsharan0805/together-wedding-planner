# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rubygems/package'

class AdminMailer < ApplicationMailer
  def attendance_change_email
    @guest = Guest.find(params[:guest_id])
    ActsAsTenant.with_tenant(@guest.wedding) do
      mail(
        to: recipients,
        subject: I18n.t(
          'admin_mailer.attendance_change_email.subject',
          name: @guest.name,
          status: I18n.t("active_record.attributes.guest/status.#{@guest.status}")
        )
      )
    end
  end

  def invitations_pdf_email
    wedding = Wedding.find(params[:wedding_id])
    ActsAsTenant.with_tenant(wedding) do
      output_file = Tempfile.new(['invitations', '.tar.gz'])
      output_path = output_file.path
      output_file.close!

      File.open(output_path, 'wb') do |file|
        Zlib::GzipWriter.wrap(file) do |gzip|
          Gem::Package::TarWriter.new(gzip) do |tar|
            Invitation.includes(:guests).find_each do |invitation|
              html = ActionController::Base.new.render_to_string(
                template: 'invitations/sheet',
                layout: 'pdf',
                locals: {
                  invitations: [invitation],
                  invitation_config: Settings.first.invitation_config
                }
              )

              img_data = IMGKit.new(html, quality: 50).to_img(:png)
              tar.add_file_simple("invitation_#{invitation.id}.png", 0o644, img_data.bytesize) { it.write(img_data) }
            end
          end
        end
      end

      blob = ActiveStorage::Blob.create_and_upload!(io: File.open(output_path), filename: 'invitations.tar.gz')
      wedding.downloads.attach(blob)

      @invitations_url = Rails.application.routes.url_helpers.rails_blob_url(blob)

      mail(to: recipients, subject: I18n.t('admin_mailer.invitations_pdf_email.subject'))
    end
  end

  def wedding_deletion_request_email
    @wedding = Wedding.find(params[:wedding_id])
    mail(to: recipients, subject: I18n.t('admin_mailer.wedding_deletion_request.subject'))
  end

  private

  def recipients
    ActsAsTenant.current_tenant.users.pluck(:email)
  end
end
