class AddUniqueIndexWebsiteWeddingId < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  def change
    remove_index :websites, :wedding_id, if_exists: true, algorithm: :concurrently
    add_index :websites, :wedding_id, unique: true, if_not_exists: true, algorithm: :concurrently
  end
end
