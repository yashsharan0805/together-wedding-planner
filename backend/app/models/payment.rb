# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id             :uuid             not null, primary key
#  amount         :decimal(10, 2)   not null
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  cost_center_id :uuid
#  expense_id     :uuid             not null
#  wedding_id     :uuid             not null
#
# Indexes
#
#  index_payments_on_cost_center_id  (cost_center_id)
#  index_payments_on_expense_id      (expense_id)
#  index_payments_on_wedding_id      (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (cost_center_id => cost_centers.id) ON DELETE => nullify
#  fk_rails_...  (expense_id => expenses.id) ON DELETE => cascade
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Payment < ApplicationRecord
  self.ignored_columns += [:paid_on]
  acts_as_tenant :wedding
  belongs_to :expense
  belongs_to :cost_center, optional: true

  self.implicit_order_column = :created_at

  validates :amount, presence: true
end
