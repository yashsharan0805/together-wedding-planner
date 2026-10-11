# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class AddGroupToGuest < ActiveRecord::Migration[7.1]
  def change
    add_reference :guests, :group, null: false, foreign_key: true, type: :uuid
  end
end
