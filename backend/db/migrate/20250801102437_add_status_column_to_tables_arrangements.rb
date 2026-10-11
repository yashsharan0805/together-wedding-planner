class AddStatusColumnToTablesArrangements < ActiveRecord::Migration[8.0]
  def change
    add_column :tables_arrangements, :status, :string, default: :complete, null: false
  end
end
