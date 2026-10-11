# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class AddWeddingIdToModels < ActiveRecord::Migration[8.0]
  def change
    [:expenses, :guests, :seats, :tables_arrangements, :groups, :users].each do |table|
      add_reference table, :wedding, type: :uuid, null: false, foreign_key: true
    end
  end
end
