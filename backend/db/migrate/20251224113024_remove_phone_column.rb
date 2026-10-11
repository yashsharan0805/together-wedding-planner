class RemovePhoneColumn < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :guests, :phone, :string }
  end
end
