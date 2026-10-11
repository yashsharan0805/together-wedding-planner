# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CleanOldDownloadsJob do
  describe '#perform' do
    it "removes the downlods created more than #{Wedding::DOWNLOAD_EXPIRATION.in_hours.round} hours ago" do
      wedding = create(:wedding)

      travel_to((Wedding::DOWNLOAD_EXPIRATION + 1.minute).ago) do
        wedding.downloads.attach(
          io: File.open('app/assets/images/sample-background.jpg'),
          filename: 'foo'
        )
      end

      new_attachment_id = wedding.downloads.attach(
        io: File.open('app/assets/images/sample-background.jpg'),
        filename: 'bar'
      ).record.id

      expect { described_class.new.perform }.to change(ActiveStorage::Attachment, :count).by(-1)
      expect(ActiveStorage::Attachment.find { it.record.id == new_attachment_id }).to be_present
    end
  end
end
