# frozen_string_literal: true

# == Schema Information
#
# Table name: cost_centers
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  wedding_id :uuid             not null
#
# Indexes
#
#  index_cost_centers_on_wedding_id  (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class CostCenter < ApplicationRecord
  acts_as_tenant :wedding
  has_many :payments, dependent: :nullify
  self.implicit_order_column = :created_at

  validates :name, presence: true
end
