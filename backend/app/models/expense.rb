# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

# == Schema Information
#
# Table name: expenses
#
#  id               :uuid             not null, primary key
#  amount           :decimal(, )      not null
#  category         :string
#  lock_version     :integer          default(0), not null
#  name             :string           not null
#  pricing_type     :enum             default("fixed"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  wedding_event_id :uuid
#  wedding_id       :uuid             not null
#
# Indexes
#
#  index_expenses_on_wedding_event_id  (wedding_event_id)
#  index_expenses_on_wedding_id        (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_event_id => wedding_events.id) ON DELETE => nullify
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Expense < ApplicationRecord
  acts_as_tenant :wedding
  belongs_to :wedding_event, optional: true
  enum :pricing_type,
       fixed: 'fixed',
       per_person: 'per_person'

  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :pricing_type, presence: true

  has_many :payments, dependent: :delete_all

  self.implicit_order_column = :created_at
end
