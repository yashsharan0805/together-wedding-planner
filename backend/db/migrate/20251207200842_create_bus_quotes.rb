class CreateBusQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :bus_quotes, id: :uuid do |t|
      t.references :wedding, null: false, foreign_key: {on_delete: :cascade }, type: :uuid
      t.references :bus_trip, null: false, foreign_key: {on_delete: :cascade}, type: :uuid
      t.string :company, null: false
      t.jsonb :prices, null: false, default: {}

      t.timestamps
    end
  end
end
