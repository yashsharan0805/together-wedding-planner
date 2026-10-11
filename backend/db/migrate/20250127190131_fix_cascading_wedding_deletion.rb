class FixCascadingWeddingDeletion < ActiveRecord::Migration[8.0]
  def change
    [:expenses, :groups, :guests, :seats, :tables_arrangements, :users].each do |table|
      remove_foreign_key table, :weddings, column: :wedding_id
      add_foreign_key table, :weddings, on_delete: :cascade
    end
  end
end
