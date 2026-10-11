# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  id                            :uuid             not null, primary key
#  confirmation_token            :string
#  confirmation_token_expires_at :datetime
#  confirmed_at                  :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  user_id                       :uuid             not null
#  wedding_id                    :uuid             not null
#
# Indexes
#
#  index_memberships_on_confirmation_token      (confirmation_token) UNIQUE
#  index_memberships_on_user_id_and_wedding_id  (user_id,wedding_id) UNIQUE
#  index_memberships_on_wedding_id              (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Membership < ApplicationRecord
  acts_as_tenant :wedding
  belongs_to :user

  self.implicit_order_column = :created_at

  validates :user_id, uniqueness: { scope: :wedding_id }
  validates :confirmation_token, uniqueness: true, allow_nil: true

  delegate :email, to: :user, prefix: :user

  def status
    return :expired if confirmation_token_expires_at&.past?
    return :pending if confirmation_token_expires_at&.future?
    return :active if  confirmation_token.nil? || confirmed_at.past?

    raise 'Unknown membership status'
  end
end
