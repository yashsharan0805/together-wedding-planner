class AddMenuRestrictionsToGuests < ActiveRecord::Migration[8.1]
  def change
    add_column :guests, :menu_restrictions, :text
  end
end
