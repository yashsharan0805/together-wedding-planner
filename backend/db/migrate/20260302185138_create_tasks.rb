# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks, id: :uuid do |t|
      t.references :wedding, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :title, null: false
      t.timestamp :completed_at

      t.timestamps
    end
  end
end
