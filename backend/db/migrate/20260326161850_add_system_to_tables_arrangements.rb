class AddSystemToTablesArrangements < ActiveRecord::Migration[8.1]
  def change
    add_column :tables_arrangements, :system, :boolean, null: false, default: false
  end
end
