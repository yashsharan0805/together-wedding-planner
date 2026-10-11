class CreateBusTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :bus_trips, id: :uuid do |t|
      t.references :wedding, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :name, null: false

      t.timestamps
    end
  end
end
