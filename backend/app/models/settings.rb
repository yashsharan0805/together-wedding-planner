# frozen_string_literal: true

# == Schema Information
#
# Table name: settings
#
#  id                   :uuid             not null, primary key
#  budget               :decimal(14, 2)   default(0.0), not null
#  bus_management       :boolean          default(FALSE), not null
#  currency             :string           default("INR"), not null
#  date                 :date
#  display_menu_choices :boolean          default(TRUE), not null
#  lock_version         :integer          default(0), not null
#  partner_one          :string
#  partner_two          :string
#  venue                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  wedding_id           :uuid             not null
#
# Indexes
#
#  index_settings_on_wedding_id  (wedding_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Settings < ApplicationRecord
  acts_as_tenant :wedding

  has_one :invitation_config, dependent: :delete
  accepts_nested_attributes_for :invitation_config, update_only: true

  self.ignored_columns += [:engine_message_broker]
  self.implicit_order_column = :created_at
  self.table_name = 'settings'

  validates :wedding_id, uniqueness: true
  validates :budget, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, inclusion: { in: %w[INR USD GBP EUR AED] }
  validates :partner_one, :partner_two, :venue, length: { maximum: 250 }

  after_create :set_invitation_config

  private

  def set_invitation_config
    # The hosted Together UI has no invitation artwork/uploads. Avoid creating
    # local files or attachment jobs in a stateless container.
    return if ENV['TOGETHER_HOSTED'] == 'true'

    InvitationConfig.create!(settings: self)
  end
end
