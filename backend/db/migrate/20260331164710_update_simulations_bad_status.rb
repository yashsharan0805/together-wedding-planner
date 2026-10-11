class UpdateSimulationsBadStatus < ActiveRecord::Migration[8.1]
  def up
    TablesArrangement.unscoped.where(status: :complete).update_all(status: :completed)
  end

  def down
    # No-op
  end
end
