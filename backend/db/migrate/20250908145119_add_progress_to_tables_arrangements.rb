class AddProgressToTablesArrangements < ActiveRecord::Migration[8.0]
  def change
    add_column :tables_arrangements, :progress, :float, default: 0, null: false
  end
end
