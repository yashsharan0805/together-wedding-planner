# frozen_string_literal: true

class CleanOldDownloadsJob < ApplicationJob
  queue_as :default

  def perform
    ActiveStorage::Attachment.where(
      record_type: Wedding.name,
      name: :downloads,
      created_at: ..Wedding::DOWNLOAD_EXPIRATION.ago
    ).find_each(&:purge)
  end
end
