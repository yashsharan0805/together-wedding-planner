class CreateWebsites < ActiveRecord::Migration[8.0]
  def change
    create_table :websites do |t|
      t.text :content
      t.references :wedding, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
