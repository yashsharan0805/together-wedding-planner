# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class AddStatusToGuest < ActiveRecord::Migration[7.1]
  def change
    add_column :guests, :status, :integer, default: 0
  end
end
