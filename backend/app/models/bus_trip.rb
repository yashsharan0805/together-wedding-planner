# frozen_string_literal: true

# == Schema Information
#
# Table name: bus_trips
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  wedding_id :uuid             not null
#
# Indexes
#
#  index_bus_trips_on_wedding_id  (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class BusTrip < ApplicationRecord
  acts_as_tenant :wedding
  has_many :bus_quotes, dependent: :delete_all

  validates :name, presence: true

  self.implicit_order_column = :created_at
end
