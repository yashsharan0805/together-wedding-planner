# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class CreateSeats < ActiveRecord::Migration[7.1]
  def change
    create_table :seats, id: :uuid do |t|
      t.references :guest, null: false, foreign_key: true, type: :uuid
      t.references :tables_arrangement, null: false, type: :uuid
      t.integer :table_number

      t.timestamps
    end

    add_foreign_key :seats, :tables_arrangements, on_delete: :cascade
  end
end
