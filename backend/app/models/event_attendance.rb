# frozen_string_literal: true

# == Schema Information
#
# Table name: event_attendances
#
#  id               :uuid             not null, primary key
#  status           :string           default("invited"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  guest_id         :uuid             not null
#  wedding_event_id :uuid             not null
#  wedding_id       :uuid             not null
#
# Indexes
#
#  index_event_attendances_on_guest_id                       (guest_id)
#  index_event_attendances_on_guest_id_and_wedding_event_id  (guest_id,wedding_event_id) UNIQUE
#  index_event_attendances_on_wedding_event_id               (wedding_event_id)
#  index_event_attendances_on_wedding_id                     (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (guest_id => guests.id) ON DELETE => cascade
#  fk_rails_...  (wedding_event_id => wedding_events.id) ON DELETE => cascade
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class EventAttendance < ApplicationRecord
  acts_as_tenant :wedding
  belongs_to :guest
  belongs_to :wedding_event
  validates :status, inclusion: { in: %w[invited confirmed declined tentative considered] }
  validates :guest_id, uniqueness: { scope: :wedding_event_id }
  validate :same_wedding

  private

  def same_wedding
    return if guest&.wedding_id == wedding_id && wedding_event&.wedding_id == wedding_id

    errors.add(:base, 'Guest and event must belong to this wedding')
  end
end
