class CreateBuses < ActiveRecord::Migration[8.1]
  def change
    create_table :buses, id: :uuid do |t|
      t.references :wedding, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.integer :seats, null: false

      t.timestamps
    end

    add_check_constraint :buses, "seats > 0", name: "positive_seats"
  end
end
