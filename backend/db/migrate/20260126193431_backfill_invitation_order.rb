class BackfillInvitationOrder < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!
  def up
    Guest.unscoped.where.not(invitation_id: nil).find_each.with_index do |guest, i|
      guest.update_columns(invitation_order: i)  # We don't care the order does not start with 0 for each invitation
    end
  end

  def down
    # No-op
  end
end
