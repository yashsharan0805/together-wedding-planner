# frozen_string_literal: true

class MigrateOldWebsiteBuilder < ActiveRecord::Migration[8.1]
  def up
    Website.where(version: 'v1.0').update_all(version: 'v2.0')
  end

  def down
    # No-op
  end
end
