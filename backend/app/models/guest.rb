# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

# == Schema Information
#
# Table name: guests
#
#  id                :uuid             not null, primary key
#  email             :string
#  invitation_order  :integer
#  lock_version      :integer          default(0), not null
#  menu_restrictions :text
#  name              :string           not null
#  needs_bus         :boolean          default(TRUE), not null
#  phone             :string
#  side              :string           default("Both"), not null
#  special_requests  :string
#  status            :integer          default("considered"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  group_id          :uuid
#  invitation_id     :uuid
#  menu_option_id    :uuid
#  wedding_id        :uuid             not null
#
# Indexes
#
#  index_guests_on_group_id                            (group_id)
#  index_guests_on_invitation_id_and_invitation_order  (invitation_id,invitation_order) UNIQUE
#  index_guests_on_menu_option_id                      (menu_option_id)
#  index_guests_on_wedding_id                          (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (invitation_id => invitations.id)
#  fk_rails_...  (menu_option_id => menu_options.id) ON DELETE => nullify
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Guest < ApplicationRecord
  MAX_INT = (2**31) - 1
  private_constant :MAX_INT
  acts_as_tenant :wedding
  belongs_to :group, optional: true
  belongs_to :invitation, optional: true
  belongs_to :menu_option, optional: true

  # We use this value in the simulations engine, which knows nothing about the Seat model
  # I don't like it, and we will probably refactor it sooner or later.
  # See https://codeberg.org/LibreWeddingPlanner/libre-wedding-planner-backend/issues/124

  attr_accessor :pinned

  enum :status, {
    considered: 0,
    invited: 10,
    confirmed: 20,
    declined: 30,
    tentative: 40
  }, validate: true

  NON_POTENTIAL_STATUSES = %w[declined considered].freeze
  POTENTIAL_STATUSES = (Guest.statuses.keys - NON_POTENTIAL_STATUSES).freeze
  private_constant :NON_POTENTIAL_STATUSES, :POTENTIAL_STATUSES

  self.ignored_columns += [:menu_choice]

  DEFAULT_MENU_OPTIONS = %w[meat fish vegetarian child].freeze

  validates :name, presence: true
  validates :invitation_order, uniqueness: { scope: :invitation_id }, if: :invitation_order

  scope :potential, -> { where.not(status: NON_POTENTIAL_STATUSES) }

  has_many :event_attendances, dependent: :delete_all
  has_many :seats, dependent: :delete_all

  self.implicit_order_column = :created_at

  delegate :color, to: :group, allow_nil: true

  before_save ->(guest) { guest.invitation_order = rand(MAX_INT) },
              if: -> { invitation_id.present? || invitation.present? },
              unless: -> { invitation_order.present? }

  before_save ->(guest) { guest.invitation_order = nil },
              if: -> { invitation_id.blank? && invitation.blank? },
              unless: -> { invitation_order.nil? }

  after_destroy ->(guest) { guest.wedding.needs_optimization! },
                if: -> { status.in?(POTENTIAL_STATUSES) }

  after_save ->(guest) { guest.wedding.needs_optimization! },
             if: :needs_to_refresh_simulation?

  def menu_choice
    menu_option&.name
  end

  private

  def needs_to_refresh_simulation?
    return true if saved_change_to_status? && (saved_changes[:status] - POTENTIAL_STATUSES).count.odd?
    return true if saved_change_to_group_id? && status.in?(POTENTIAL_STATUSES)

    false
  end
end
