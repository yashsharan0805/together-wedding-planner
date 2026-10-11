# frozen_string_literal: true

class NullifyParentIdOnGroupDeletion < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :groups, :groups, column: 'parent_id'
    add_foreign_key :groups, :groups, column: 'parent_id', on_delete: :nullify
  end
end
