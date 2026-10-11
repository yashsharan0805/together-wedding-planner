# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups, id: :uuid do |t|
      t.string :name, null: false
      t.string :icon
      t.integer :order, null: false, default: 1

      t.timestamps
    end

    add_index :groups, :name, unique: true
  end
end
