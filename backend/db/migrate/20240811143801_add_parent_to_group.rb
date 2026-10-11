# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class AddParentToGroup < ActiveRecord::Migration[7.1]
  def change
    add_reference :groups, :parent, type: :uuid, index: true, foreign_key: { to_table: :groups }
  end
end
