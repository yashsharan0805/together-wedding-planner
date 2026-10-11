class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings, id: :uuid do |t|
      t.references :wedding, null: false, foreign_key: { on_delete: :cascade }, type: :uuid, index: { unique: true }
      t.date :date

      t.timestamps
    end
  end
end
