# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class RemoveEmailFromGuests < ActiveRecord::Migration[7.2]
  def change
    remove_column :guests, :email, :string
  end
end
