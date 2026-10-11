class ValidateConstraintInvitationOrder < ActiveRecord::Migration[8.1]
  def change
    validate_check_constraint :guests, name: :invitation_order_consistency
  end
end
