class DropSeatsTableNumberColumn < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :seats, :table_number, :integer }
  end
end
