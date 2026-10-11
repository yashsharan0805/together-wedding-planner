# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

# == Schema Information
#
# Table name: websites
#
#  id         :uuid             not null, primary key
#  content    :text
#  domain     :string
#  pages      :jsonb            not null, is an Array
#  version    :string           default("v2.0"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  wedding_id :uuid             not null
#
# Indexes
#
#  index_websites_on_wedding_id     (wedding_id) UNIQUE
#  uindex_websites_on_lower_domain  (lower((domain)::text)) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Website < ApplicationRecord
  DOMAIN_REGEX = /\A(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}\z/i
  KNOWN_VERSIONS = ['v1.0', 'v2.0'].freeze
  private_constant :DOMAIN_REGEX

  belongs_to :wedding

  attribute :pages, :page, array: true, presence: true

  validates :domain, format: { with: DOMAIN_REGEX }, uniqueness: { case_sensitive: false }, allow_nil: true
  validates :version, inclusion: { in: KNOWN_VERSIONS }, presence: true
  validates :wedding_id, uniqueness: true
  validate :slug_validations

  self.implicit_order_column = :created_at

  private

  def slug_validations
    return unless pages.is_a?(Array)

    errors.add(:pages, 'must be case-insensitive unique') if pages.map { it.slug.downcase }.uniq.size != pages.size
    errors.add(:pages, 'must have a page without slug acting as root') if pages.none? { it.slug.empty? }
  end
end
