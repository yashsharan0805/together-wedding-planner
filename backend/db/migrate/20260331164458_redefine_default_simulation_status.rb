class RedefineDefaultSimulationStatus < ActiveRecord::Migration[8.1]
  def change
    change_column_default :tables_arrangements, :status, from: :complete, to: :not_started
  end
end
