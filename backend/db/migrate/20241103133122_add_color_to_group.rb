# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class AddColorToGroup < ActiveRecord::Migration[7.2]
  def change
    add_column :groups, :color, :string
  end
end
