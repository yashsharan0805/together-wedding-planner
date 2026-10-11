class AddIndexInvitationOrder < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :guests, [:invitation_id, :invitation_order], unique: true, algorithm: :concurrently
  end
end