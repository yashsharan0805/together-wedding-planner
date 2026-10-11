# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

# == Schema Information
#
# Table name: invitations
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  wedding_id :uuid             not null
#
# Indexes
#
#  index_invitations_on_wedding_id  (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Invitation < ApplicationRecord
  acts_as_tenant :wedding
  has_many :guests, -> { order(invitation_order: :asc) }, dependent: :nullify, inverse_of: :invitation

  self.implicit_order_column = :created_at

  # The invitation would be nullified due to the dependend: :nullify config but we also need to nullify the order
  before_destroy ->(invitation) { invitation.guests.update_all(invitation_id: nil, invitation_order: nil) },
                 prepend: true

  def url
    if (custom_domain = wedding.website&.domain)
      "https://#{custom_domain}/invitation/#{id}"
    else
      slug = ActsAsTenant.current_tenant.slug
      "#{Rails.application.routes.url_helpers.root_url(slug:)}/site/invitation/#{id}".sub('/api/', '/')
    end
  end

  def title
    name.presence || guests.reject(&:considered?).map(&:name).join(' & ')
  end
end
