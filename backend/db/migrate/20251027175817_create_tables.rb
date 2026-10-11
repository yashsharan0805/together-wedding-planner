class CreateTables < ActiveRecord::Migration[8.0]
  def change
    create_table :tables, id: :uuid do |t|
      t.references :wedding, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :tables_arrangement, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.integer :number, null: false
      t.int4range :capacity, null: false
      t.string :name

      t.timestamps
    end

    add_check_constraint :tables, 'number > 0',
                         if_not_exists: true,
                         name: 'number_positive'
    add_check_constraint :tables, 'lower(capacity) > 0 AND upper(capacity) >= lower(capacity)',
                         name: 'capacity_bounds_positive',
                         if_not_exists: true

    add_index :tables, 
    [:wedding_id, :tables_arrangement_id, :number],
     unique: true,
      name: 'index_tables_on_wedding_id_and_number',
      if_not_exists: true
  end
end
