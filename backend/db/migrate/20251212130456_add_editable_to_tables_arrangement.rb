class AddEditableToTablesArrangement < ActiveRecord::Migration[8.1]
  def change
    add_column :tables_arrangements, :editable, :boolean, null: false, default: false
  end
end
