# frozen_string_literal: true

# == Schema Information
#
# Table name: locations
#
#  id           :uuid             not null, primary key
#  display_name :string           not null
#  label        :string           not null
#  latitude     :decimal(, )      not null
#  longitude    :decimal(, )      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  place_id     :bigint           not null
#  wedding_id   :uuid             not null
#
# Indexes
#
#  index_locations_on_wedding_id  (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Location < ApplicationRecord
  acts_as_tenant(:wedding)

  self.implicit_order_column = :created_at

  validates :place_id, :label, :display_name, presence: true
  validates :latitude, presence: true, numericality: { in: -90..90 }
  validates :longitude, presence: true, numericality: { in: -180..180 }
end
