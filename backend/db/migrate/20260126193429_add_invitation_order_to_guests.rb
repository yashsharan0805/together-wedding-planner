class AddInvitationOrderToGuests < ActiveRecord::Migration[8.1]
  def change
    add_column :guests, :invitation_order, :integer
    add_check_constraint :guests, '(invitation_id IS NOT NULL) = (invitation_order IS NOT NULL)', name: "invitation_order_consistency", validate: false
  end
end
