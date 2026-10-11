class RemoveAncestorIdColumn < ActiveRecord::Migration[8.1]
  def up
    safety_assured { remove_column :tables_arrangements, :ancestor_id }
  end

  def down
    add_column :tables_arrangements, :ancestor_id, :uuid
    add_foreign_key :tables_arrangements, :tables_arrangements, column: :ancestor_id, on_delete: :nullify
    add_index :tables_arrangements, :ancestor_id
  end
end
