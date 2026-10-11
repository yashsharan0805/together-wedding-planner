# frozen_string_literal: true

class CreateEngineStats < ActiveRecord::Migration[8.1]
  def change
    create_table :engine_stats do |t|
      t.references :tables_arrangement, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: false

      t.integer :iteration, null: false, precision: 2
      t.float :user_time, null: false
      t.float :system_time, null: false
      t.float :total_time, null: false
      t.float :real_time, null: false
      t.bigint :evaluation_count, null: false

      t.timestamps
    end

    add_index :engine_stats, %i[tables_arrangement_id iteration], unique: true
  end
end
