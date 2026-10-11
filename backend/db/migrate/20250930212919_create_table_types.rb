class CreateTableTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :table_types, id: :uuid do |t|
      t.references :wedding, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.int4range :capacity, null: false
      t.integer :availability, limit: 2, null: true
      t.timestamps

      t.check_constraint "lower(capacity) > 0 AND upper(capacity) >= lower(capacity)", name: "capacity_bounds_positive"
      t.check_constraint "availability IS NULL OR availability > 0", name: "availability_positive_or_null"
    end
  end
end
