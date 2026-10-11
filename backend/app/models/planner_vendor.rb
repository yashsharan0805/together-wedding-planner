# frozen_string_literal: true

# == Schema Information
#
# Table name: planner_vendors
#
#  id               :uuid             not null, primary key
#  category         :string
#  contact          :string
#  lock_version     :integer          default(0), not null
#  name             :string           not null
#  notes            :text
#  status           :string           default("Shortlisted"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  wedding_event_id :uuid
#  wedding_id       :uuid             not null
#
# Indexes
#
#  index_planner_vendors_on_wedding_event_id  (wedding_event_id)
#  index_planner_vendors_on_wedding_id        (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_event_id => wedding_events.id) ON DELETE => nullify
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class PlannerVendor < ApplicationRecord
  acts_as_tenant :wedding
  belongs_to :wedding_event, optional: true
  has_many :documents, class_name: 'PlannerDocument', dependent: :delete_all
  validates :name, presence: true, length: { maximum: 120 }
  validates :status, inclusion: { in: ['Shortlisted', 'Contacted', 'Booked'] }
  validates :contact, :category, length: { maximum: 250 }
  validates :notes, length: { maximum: 3000 }
  validate :same_wedding

  private

  def same_wedding
    errors.add(:wedding_event, 'must belong to this wedding') if wedding_event && wedding_event.wedding_id != wedding_id
  end
end
