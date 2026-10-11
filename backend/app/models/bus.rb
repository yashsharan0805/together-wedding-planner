# frozen_string_literal: true

# == Schema Information
#
# Table name: buses
#
#  id         :uuid             not null, primary key
#  seats      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  wedding_id :uuid             not null
#
# Indexes
#
#  index_buses_on_wedding_id  (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Bus < ApplicationRecord
  acts_as_tenant(:wedding)

  scope :with_number, -> { select('buses.*', Arel.sql('row_number() over(order by seats desc, id asc) as number')) }

  validates :seats, numericality: { greater_than: 0, only_integer: true }

  self.implicit_order_column = :created_at
end
