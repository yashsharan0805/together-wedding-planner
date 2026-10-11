# frozen_string_literal: true

class AddTrackableToDevise < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :last_sign_in_at, :datetime
  end
end
