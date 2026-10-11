# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations, id: :uuid do |t|
      t.references :wedding, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.bigint :place_id, null: false
      t.decimal :latitude, null: false
      t.decimal :longitude, null: false
      t.string :label, null: false
      t.string :display_name, null: false

      t.timestamps
    end

    add_check_constraint :locations, 'latitude between -90 and 90', name: 'latitude_range'
    add_check_constraint :locations, 'longitude between -180 and 180', name: 'longitude_range'
  end
end
