class CreateCostCenters < ActiveRecord::Migration[8.1]
  def change
    create_table :cost_centers, id: :uuid do |t|
      t.references :wedding, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :name, null: false

      t.timestamps
    end
  end
end
