class MakeColumnsNotNull < ActiveRecord::Migration[8.0]
  def change
    change_column_null :guests, :name, false
    change_column_null :expenses, :name, false
    change_column_null :expenses, :amount, false
  end
end
