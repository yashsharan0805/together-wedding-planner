class AddPinnedColumnToGuests < ActiveRecord::Migration[8.1]
  def change
    add_column :seats, :pinned, :boolean, null: false, default: false
  end
end
