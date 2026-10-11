require 'webdack/uuid_migration/helpers'

class ConvertWebsiteIdToUuid < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        safety_assured do
          primary_key_and_all_references_to_uuid :websites, seed: SecureRandom.uuid
        end
      end

      dir.down do
        # no-op
      end
    end
  end
end
