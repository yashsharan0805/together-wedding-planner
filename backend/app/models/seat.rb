# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

# == Schema Information
#
# Table name: seats
#
#  id                    :uuid             not null, primary key
#  pinned                :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  guest_id              :uuid             not null
#  table_id              :uuid             not null
#  tables_arrangement_id :uuid             not null
#  wedding_id            :uuid             not null
#
# Indexes
#
#  index_seats_on_guest_id               (guest_id)
#  index_seats_on_table_id               (table_id)
#  index_seats_on_tables_arrangement_id  (tables_arrangement_id)
#  index_seats_on_wedding_id             (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (guest_id => guests.id) ON DELETE => cascade
#  fk_rails_...  (table_id => tables.id) ON DELETE => cascade
#  fk_rails_...  (tables_arrangement_id => tables_arrangements.id) ON DELETE => cascade
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Seat < ApplicationRecord
  acts_as_tenant :wedding
  belongs_to :guest
  belongs_to :tables_arrangement
  belongs_to :table

  self.implicit_order_column = :created_at
  self.ignored_columns += ['table_number']
end
