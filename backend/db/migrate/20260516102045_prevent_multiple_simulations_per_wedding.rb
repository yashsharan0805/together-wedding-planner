# frozen_string_literal: true

class PreventMultipleSimulationsPerWedding < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!
  def change
    add_index :tables_arrangements,
              :wedding_id,
              unique: true,
              name: :uindex_tables_arrangements_on_wedding_id,
              if_not_exists: true,
              algorithm: :concurrently

    remove_index :tables_arrangements,
                 :wedding_id,
                 unique: false,
                 name: :index_tables_arrangements_on_wedding_id,
                 if_exists: true,
                 algorithm: :concurrently

    remove_index :tables_arrangements,
                 :wedding_id,
                 unique: true,
                 where: 'system IS TRUE',
                 name: :uindex_wedding_id_system,
                 if_exists: true,
                 algorithm: :concurrently
  end
end
