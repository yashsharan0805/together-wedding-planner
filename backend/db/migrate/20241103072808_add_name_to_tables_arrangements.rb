# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class AddNameToTablesArrangements < ActiveRecord::Migration[7.2]
  def change
    add_column :tables_arrangements, :name, :string, null: false
  end
end
