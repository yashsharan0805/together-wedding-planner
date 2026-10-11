# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class AllowUngroupedGuests < ActiveRecord::Migration[8.0]
  def change
    change_column_null :guests, :group_id, true
  end
end
