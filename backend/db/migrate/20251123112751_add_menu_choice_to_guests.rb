class AddMenuChoiceToGuests < ActiveRecord::Migration[8.1]
  def change
    add_column :guests, :menu_choice, :integer
  end
end
