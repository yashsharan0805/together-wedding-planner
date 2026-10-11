# frozen_string_literal: true

class BackfillMemberships < ActiveRecord::Migration[8.1]
  def up
    records = User.unscoped.pluck(:id, :wedding_id).map { |(user_id, wedding_id)| { user_id:, wedding_id: } }
    Membership.insert_all(records)
  end

  def down
    # No-op
  end
end
