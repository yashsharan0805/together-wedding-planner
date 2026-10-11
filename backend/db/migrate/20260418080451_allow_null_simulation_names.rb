class AllowNullSimulationNames < ActiveRecord::Migration[8.1]
  def change
    change_column_default :tables_arrangements, :name, from: nil, to: "nameless"
    change_column_null :tables_arrangements, :name, true
  end
end
