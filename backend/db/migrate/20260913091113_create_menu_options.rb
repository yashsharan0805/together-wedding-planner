# frozen_string_literal: true

class CreateMenuOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_options, id: :uuid do |t|
      t.references :wedding, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :name, null: false
      t.string :i18n_key

      t.timestamps
    end
  end
end
