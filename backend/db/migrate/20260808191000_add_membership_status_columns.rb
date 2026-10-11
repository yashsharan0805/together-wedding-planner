# frozen_string_literal: true

class AddMembershipStatusColumns < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      change_table :memberships, bulk: true do |t|
        t.timestamp :confirmed_at
        t.string :confirmation_token, index: { unique: true }
        t.timestamp :confirmation_token_expires_at
      end
    end
  end
end
