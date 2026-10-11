# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

# == Schema Information
#
# Table name: group_affinities
#
#  id         :bigint           not null, primary key
#  discomfort :float            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_a_id :uuid             not null
#  group_b_id :uuid             not null
#
# Indexes
#
#  index_group_affinities_on_group_a_id  (group_a_id)
#  index_group_affinities_on_group_b_id  (group_b_id)
#  uindex_group_pair                     (LEAST(group_a_id, group_b_id), GREATEST(group_a_id, group_b_id)) UNIQUE
#
# Foreign Keys
#
#  fk_rails_group_a_id  (group_a_id => groups.id) ON DELETE => cascade
#  fk_rails_group_b_id  (group_b_id => groups.id) ON DELETE => cascade
#
class GroupAffinity < ApplicationRecord
  NEUTRAL = 1
  MIN_DISCOMFORT = 0
  MAX_DISCOMFORT = 2

  belongs_to :group_a, class_name: 'Group'
  belongs_to :group_b, class_name: 'Group'

  validates :discomfort,
            numericality: { greater_than_or_equal_to: MIN_DISCOMFORT, less_than_or_equal_to: MAX_DISCOMFORT }

  def another_group(group)
    return nil if group != group_a && group != group_b

    group == group_a ? group_b : group_a
  end
end
