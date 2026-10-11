# frozen_string_literal: true

class ConsiderExistingMembershipsConfirmed < ActiveRecord::Migration[8.1]
  def up
    Membership.update_all(confirmed_at: Time.zone.now)
  end

  def down
    Membership.update_all(confirmed_at: nil)
  end
end
