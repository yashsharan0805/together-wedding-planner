# frozen_string_literal: true

# == Schema Information
#
# Table name: bus_quotes
#
#  id          :uuid             not null, primary key
#  company     :string           not null
#  prices      :jsonb            not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  bus_trip_id :uuid             not null
#  wedding_id  :uuid             not null
#
# Indexes
#
#  index_bus_quotes_on_bus_trip_id  (bus_trip_id)
#  index_bus_quotes_on_wedding_id   (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (bus_trip_id => bus_trips.id) ON DELETE => cascade
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class BusQuote < ApplicationRecord
  acts_as_tenant :wedding
  belongs_to :bus_trip

  validates :company, :prices, presence: true
  validate :price_format

  self.implicit_order_column = :created_at

  private

  def price_format
    return if prices.is_a?(Array) &&
              prices.all? { |config| valid_price?(config:) } &&
              prices.pluck('capacity').uniq.count == prices.count

    errors.add(:prices,
               'must be an array of hashes with positive "price" and unique, positive, integer "capacity" keys')
  end

  def valid_price?(config:)
    return false if config.keys.count != 2

    price, capacity = config.values_at('price', 'capacity')
    capacity.is_a?(Integer) && capacity.positive? && price.is_a?(Numeric) && price.positive?
  end
end
