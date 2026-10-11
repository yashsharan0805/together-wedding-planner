# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

# == Schema Information
#
# Table name: groups
#
#  id         :uuid             not null, primary key
#  color      :string
#  icon       :string
#  name       :string           not null
#  order      :integer          default(1), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :uuid
#  wedding_id :uuid             not null
#
# Indexes
#
#  index_groups_on_parent_id            (parent_id)
#  index_groups_on_wedding_id_and_name  (wedding_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => groups.id) ON DELETE => nullify
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Group < ApplicationRecord
  acts_as_tenant :wedding

  validates :name, uniqueness: { scope: :wedding_id }
  validates :name, :order, presence: true

  has_many :children, class_name: 'Group', foreign_key: 'parent_id', dependent: :nullify, inverse_of: :parent
  belongs_to :parent, class_name: 'Group', optional: true

  before_create :set_color

  after_destroy ->(group) { group.wedding.needs_optimization! }

  scope :roots, -> { where(parent_id: nil) }

  has_many :guests, dependent: :nullify

  self.implicit_order_column = :created_at

  def colorize_children(generation = 1)
    children.zip(palette(generation)) do |child, raw_color|
      final_color = raw_color.paint
      final_color.brighten(60) if final_color.dark?

      child.update!(color: final_color)

      child.colorize_children(generation + 1)
    end
  end

  def affinities
    GroupAffinity.where(group_a_id: id).or(GroupAffinity.where(group_b_id: id))
  end

  private

  def palette(generation)
    if generation == 1
      color.paint.palette.analogous(size: children.count)
    else
      color.paint.palette.decreasing_saturation
    end
  end

  def set_color
    return if color.present?

    new_color = "##{SecureRandom.hex(3)}".paint
    new_color = new_color.lighten(30) if new_color.dark?
    self.color = new_color
  end
end
