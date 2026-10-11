class AddBusManagementColumnToSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :bus_management, :boolean, null: false, default: false
  end
end
