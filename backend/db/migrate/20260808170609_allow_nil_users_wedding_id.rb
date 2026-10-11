# frozen_string_literal: true

class AllowNilUsersWeddingId < ActiveRecord::Migration[8.1]
  def change
    # We need the column to be nilable before we can ask Rails to ignore it. Otherwise, it would fail
    # when we insert a new record without this column.
    change_column_null :users, :wedding_id, true
  end
end
