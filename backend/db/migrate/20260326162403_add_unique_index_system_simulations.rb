class AddUniqueIndexSystemSimulations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!
  def change
    add_index :tables_arrangements, [:wedding_id], where: "system IS TRUE", name: :uindex_wedding_id_system, algorithm: :concurrently, unique: true, if_not_exists: true
  end
end
