class MakeSeatsGuestFkCascadeDelete < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :seats, :guests
    add_foreign_key :seats, :guests, on_delete: :cascade
  end
end
