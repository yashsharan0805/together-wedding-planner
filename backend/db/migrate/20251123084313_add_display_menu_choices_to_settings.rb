class AddDisplayMenuChoicesToSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :display_menu_choices, :boolean, default: true, null: false
  end
end
