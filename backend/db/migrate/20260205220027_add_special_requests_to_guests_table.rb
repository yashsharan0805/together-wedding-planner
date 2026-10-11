class AddSpecialRequestsToGuestsTable < ActiveRecord::Migration[8.1]
  def change
    add_column :guests, :special_requests, :string
  end
end
