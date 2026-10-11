class RemoveRedundantIndexGuestInvitationId < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!
  def change
    remove_index :guests, :invitation_id, name: :index_guests_on_invitation_id, algorithm: :concurrently
  end
end
