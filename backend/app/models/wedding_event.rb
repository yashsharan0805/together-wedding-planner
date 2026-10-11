# frozen_string_literal: true

# == Schema Information
#
# Table name: wedding_events
#
#  id           :uuid             not null, primary key
#  date         :date             not null
#  lock_version :integer          default(0), not null
#  name         :string           not null
#  notes        :text
#  start_time   :string
#  venue        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  wedding_id   :uuid             not null
#
# Indexes
#
#  index_wedding_events_on_wedding_id  (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class WeddingEvent < ApplicationRecord
  acts_as_tenant :wedding
  has_many :event_attendances, dependent: :delete_all
  has_many :planner_vendors, dependent: :nullify
  has_many :tasks, dependent: :nullify
  has_many :expenses, dependent: :nullify

  validates :name, presence: true, length: { maximum: 120 }
  validates :date, presence: true
  validates :start_time, format: { with: /\A(?:[01]\d|2[0-3]):[0-5]\d\z/ }, allow_blank: true
  validates :venue, length: { maximum: 250 }
  validates :notes, length: { maximum: 3000 }
end
