# frozen_string_literal: true

class AddDeletionTokenToWedding < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      change_table :weddings, bulk: true do |t|
        t.string :deletion_token
        t.timestamptz :deletion_token_expires_at
      end
    end

    add_check_constraint :weddings,
                         '(deletion_token IS NULL AND deletion_token_expires_at IS NULL) OR ' \
                         '(deletion_token IS NOT NULL AND deletion_token_expires_at IS NOT NULL)',
                         if_not_exists: true,
                         name: :chk_rails_deletion_token_consistency
  end
end
