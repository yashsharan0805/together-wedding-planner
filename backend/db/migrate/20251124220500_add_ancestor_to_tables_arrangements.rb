# frozen_string_literal: true

class AddAncestorToTablesArrangements < ActiveRecord::Migration[8.0]
  def change
    add_reference :tables_arrangements, :ancestor,
                  type: :uuid,
                  null: true,
                  foreign_key: { to_table: :tables_arrangements, on_delete: :nullify }
  end
end
