# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class CreateWeddings < ActiveRecord::Migration[8.0]
  def change
    create_table :weddings, id: :uuid do |t|
      t.string :slug, null: false, index: { unique: true }
      t.date :date, null: false

      t.timestamps
    end
  end
end
