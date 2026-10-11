# frozen_string_literal: true

# == Schema Information
#
# Table name: tables
#
#  id                    :uuid             not null, primary key
#  capacity              :int4range        not null
#  name                  :string
#  number                :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  tables_arrangement_id :uuid             not null
#  wedding_id            :uuid             not null
#
# Indexes
#
#  index_tables_on_tables_arrangement_id  (tables_arrangement_id)
#  index_tables_on_wedding_id_and_number  (wedding_id,tables_arrangement_id,number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (tables_arrangement_id => tables_arrangements.id) ON DELETE => cascade
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Table < ApplicationRecord
  acts_as_tenant :wedding
  belongs_to :tables_arrangement
  has_many :seats, dependent: :delete_all
  has_many :guests, through: :seats

  validates :capacity, presence: true, capacity: true
  validates :number,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: { scope: %i[wedding_id tables_arrangement_id] }

  self.implicit_order_column = :created_at

  before_validation :set_number, on: :create
  before_validation :sanitize_name

  private

  def sanitize_name
    name = self.name&.strip
    name = nil if name.blank?
    self.name = name
  end

  def set_number
    self.number = (tables_arrangement.tables.maximum(:number) || 0) + 1 if number.nil?
  end
end
