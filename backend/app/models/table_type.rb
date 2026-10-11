# frozen_string_literal: true

# == Schema Information
#
# Table name: table_types
#
#  id           :uuid             not null, primary key
#  availability :integer
#  capacity     :int4range        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  wedding_id   :uuid             not null
#
# Indexes
#
#  index_table_types_on_wedding_id  (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class TableType < ApplicationRecord
  acts_as_tenant :wedding

  validates :capacity, presence: true, capacity: true
  validates :availability, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :ordered, -> { order(Arel.sql('lower(capacity) ASC, upper(capacity)  ASC, availability ASC')) }

  self.implicit_order_column = :created_at

  def capacity_limits
    {
      min: capacity.min,
      max: capacity.max
    }
  end
end
