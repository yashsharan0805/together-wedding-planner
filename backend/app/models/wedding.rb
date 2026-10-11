# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

# == Schema Information
#
# Table name: weddings
#
#  id                        :uuid             not null, primary key
#  deletion_token            :string
#  deletion_token_expires_at :timestamptz
#  slug                      :string           not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_weddings_on_slug  (slug) UNIQUE
#
class Wedding < ApplicationRecord
  SLUG_REGEX = /[a-z\d-]+/
  RESERVED_SLUGS = %w[jobs letter_opener captcha api system sidekiq].freeze
  DOWNLOAD_EXPIRATION = 1.day.freeze
  private_constant :RESERVED_SLUGS

  self.implicit_order_column = :created_at

  validates :slug,
            presence: true,
            uniqueness: true,
            format: { with: /\A#{SLUG_REGEX}\z/ },
            exclusion: { in: RESERVED_SLUGS }

  has_many :wedding_events, dependent: :destroy
  has_many :planner_vendors, dependent: :delete_all
  has_many :event_attendances, dependent: :delete_all
  has_many :guests, dependent: :delete_all
  has_many :groups, dependent: :delete_all
  has_many :invitations, dependent: :delete_all
  has_many :memberships, dependent: :delete_all
  has_many :users, through: :memberships
  has_many :tables_arrangements, dependent: :delete_all
  has_one :system_simulation,
          -> { where(system: true) },
          class_name: 'TablesArrangement',
          dependent: :delete,
          inverse_of: :wedding
  has_many :expenses, dependent: :delete_all
  has_many :table_types, dependent: :delete_all
  has_many :tasks, dependent: :delete_all
  has_many :seats, dependent: :delete_all
  has_one :website, dependent: :destroy
  has_one :settings, dependent: :destroy
  has_many :locations, dependent: :delete_all
  has_many :menu_options, dependent: :delete_all

  has_many_attached :downloads

  after_create ->(wedding) { wedding.create_website!(pages: [{ slug: '' }]) }
  after_create ->(wedding) { ActsAsTenant.with_tenant(wedding) { wedding.create_settings! } }
  after_create :seed_menu_options

  class << self
    def simulation_version_key(id)
      "wedding/simulations/version/#{id}"
    end
  end

  def needs_optimization!
    # Together does not expose the upstream seating simulation or its workers.
    return if ENV['TOGETHER_HOSTED'] == 'true'

    WeddingPlanner.redis.incr(simulation_version_key)

    simulation_id = tables_arrangements.where(system: true).pick(:id)

    return if simulation_id.nil?

    TablesArrangement.find(simulation_id).refresh_guests!
    Engine::TaskSerializer.new(simulation_id).call.to_json
                          .then { TaskProcessingJob.perform_async(it) }
  end

  def simulation_version
    WeddingPlanner.redis.get(simulation_version_key).to_i
  end

  def empty!
    seats.delete_all
    guests.delete_all
    groups.delete_all
    invitations.delete_all
  end

  def generate_deletion_token!
    update_columns(
      deletion_token: SecureRandom.alphanumeric(60),
      deletion_token_expires_at: 1.hour.from_now
    )
  end

  private

  def simulation_version_key
    self.class.simulation_version_key(id)
  end

  def seed_menu_options
    # The wedding creation endpoint is not wrapped in ActsAsTenant because the tenant does not
    # exist upfront. We need to set the tenant explicitly to avoid ActsAsTenant::Errors::NoTenantSet
    ActsAsTenant.with_tenant(self) do
      Guest::DEFAULT_MENU_OPTIONS.each do |choice|
        menu_options.create!(i18n_key: choice, name: choice)
      end
    end
  end
end
