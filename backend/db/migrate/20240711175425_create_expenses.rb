# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class CreateExpenses < ActiveRecord::Migration[7.1]
  def change
    create_enum :pricing_types, ["fixed", "per_person"]
    create_table :expenses, id: :uuid do |t|
      t.string :name
      t.decimal :amount
      t.enum :pricing_type, enum_type: :pricing_types, default: "fixed", null: false

      t.timestamps
    end
  end
end
