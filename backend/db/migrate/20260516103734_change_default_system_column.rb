class ChangeDefaultSystemColumn < ActiveRecord::Migration[8.1]
  def change
    change_column_default :tables_arrangements, :system, from: false, to: true
  end
end
