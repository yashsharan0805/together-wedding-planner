# frozen_string_literal: true

# == Schema Information
#
# Table name: engine_stats
#
#  id                    :bigint           not null, primary key
#  evaluation_count      :bigint           not null
#  iteration             :integer          not null
#  real_time             :float            not null
#  system_time           :float            not null
#  total_time            :float            not null
#  user_time             :float            not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  tables_arrangement_id :uuid             not null
#
# Indexes
#
#  index_engine_stats_on_tables_arrangement_id_and_iteration  (tables_arrangement_id,iteration) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (tables_arrangement_id => tables_arrangements.id) ON DELETE => cascade
#
class EngineStat < ApplicationRecord
  self.implicit_order_column = :created_at

  validates :evaluation_count, :real_time, :system_time, :user_time, :total_time, :iteration, presence: true
  validates :iteration, uniqueness: { scope: :tables_arrangement_id }

  belongs_to :tables_arrangement
end
