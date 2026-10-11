class ScopeGroupNameUniqueness < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :groups, %i[wedding_id name], unique: true, algorithm: :concurrently, if_not_exists: true
    remove_index :groups, :name, unique: true, algorithm: :concurrently, if_exists: true
    remove_index :groups, :wedding_id, algorithm: :concurrently, if_exists: true
  end
end
