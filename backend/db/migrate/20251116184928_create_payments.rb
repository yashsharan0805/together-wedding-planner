class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :wedding, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :expense, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :paid_on
      t.string :title

      t.timestamps
    end
  end
end
