class AddTableIdToSeats < ActiveRecord::Migration[8.0]
  def change
    add_reference :seats, :table, foreign_key: { on_delete: :cascade }, type: :uuid
  end
end
