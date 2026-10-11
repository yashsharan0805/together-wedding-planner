# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class MergeGuestNames < ActiveRecord::Migration[8.0]
  def change
    add_column :guests, :name, :string

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE guests
          SET name = CONCAT(first_name, ' ', last_name)
        SQL
      end
    end

    remove_column :guests, :first_name, :string
    remove_column :guests, :last_name, :string
  end
end
