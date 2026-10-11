class AddNeedsBusColumnToGuests < ActiveRecord::Migration[8.1]
  def change
    add_column :guests, :needs_bus, :boolean, null: false, default: true
  end
end
