# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

# == Schema Information
#
# Table name: tables_arrangements
#
#  id                :uuid             not null, primary key
#  discomfort        :float
#  optimized_version :integer          default(0), not null
#  progress          :float            default(0.0), not null
#  status            :string           default("not_started"), not null
#  system            :boolean          default(TRUE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  wedding_id        :uuid             not null
#
# Indexes
#
#  uindex_tables_arrangements_on_wedding_id  (wedding_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class TablesArrangement < ApplicationRecord
  self.ignored_columns += %i[digest editable name]
  acts_as_tenant :wedding

  validates :status, inclusion: { in: %w[not_started in_progress completed error] }
  validates :wedding_id, uniqueness: true, presence: true

  has_many :seats, dependent: :delete_all
  has_many :guests, through: :seats
  has_many :tables, -> { order(number: :asc) }, dependent: :delete_all, inverse_of: :tables_arrangement

  has_many :engine_stats, dependent: :delete_all

  self.implicit_order_column = :created_at
  self.ignored_columns += [:ancestor_id]

  def refresh_guests!
    return if table_ids.empty?
    ActiveRecord::Base.transaction do
      potential_guest_ids = Guest.where(wedding:).potential.pluck(:id)

      seats.where.not(guest_id: potential_guest_ids).delete_all
      (potential_guest_ids - seats.pluck(:guest_id))
        .map { { wedding_id: wedding.id, table_id: table_ids.sample, guest_id: it } }
        .then { seats.insert_all(it) }
    end
  end

  def recalculate_discomfort!
    hierarchy = AffinityGroupsHierarchy.new

    tables.includes(:guests).map { |table| Tables::Table.new(table.guests).tap { it.min_per_table = table.capacity.min }.tap { it.max_per_table = table.capacity.max } }
          .sum { Tables::DiscomfortCalculator.new(table: it, hierarchy:).calculate }
          .then { update!(discomfort: it) }
  end

  def reset!
    ActiveRecord::Base.transaction do
      seats.delete_all
      tables.delete_all
      update!(status: :not_started)
    end
  end
end
