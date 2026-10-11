class RemoveNonSystemSimulations < ActiveRecord::Migration[8.1]
  def up
    TablesArrangement.unscoped.where.not(system: true).in_batches.delete_all
  end

  def down
    # no-op
  end
end
