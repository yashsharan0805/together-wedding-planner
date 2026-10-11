# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: false, type: :uuid
      t.references :wedding, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps

      t.index %i[user_id wedding_id], unique: true
    end
  end
end
