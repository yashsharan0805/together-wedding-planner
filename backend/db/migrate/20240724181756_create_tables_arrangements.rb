# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class CreateTablesArrangements < ActiveRecord::Migration[7.1]
  def change
    create_table :tables_arrangements, id: :uuid do |t|
      t.integer :discomfort

      t.timestamps
    end
  end
end
