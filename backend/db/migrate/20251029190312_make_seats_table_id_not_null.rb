class MakeSeatsTableIdNotNull < ActiveRecord::Migration[8.0]
  def change
    change_column_null :seats, :table_id, false
  end
end
