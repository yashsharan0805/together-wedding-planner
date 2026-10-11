# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class RemoveWeddingDate < ActiveRecord::Migration[8.0]
  def change
    remove_column :weddings, :date, :date, null: false
  end
end
