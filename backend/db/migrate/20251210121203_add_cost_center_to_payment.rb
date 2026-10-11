class AddCostCenterToPayment < ActiveRecord::Migration[8.1]
  def change
    add_reference :payments, :cost_center, foreign_key: { on_delete: :nullify }, type: :uuid
  end
end
