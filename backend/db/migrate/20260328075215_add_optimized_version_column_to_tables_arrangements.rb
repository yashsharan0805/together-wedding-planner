class AddOptimizedVersionColumnToTablesArrangements < ActiveRecord::Migration[8.1]
  def change
    add_column :tables_arrangements, :optimized_version, :integer, null: false, default: 0
  end
end
