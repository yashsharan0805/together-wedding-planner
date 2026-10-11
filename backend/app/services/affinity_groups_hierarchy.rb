# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class AffinityGroupsHierarchy < Array
  DEFAULT_DISCOMFORT = 1

  def initialize
    super
    @references = {}

    Group.roots.includes([:children]).find_each do |group|
      self << group.id

      hydrate(group)
    end

    discomforts
    invitation_counts
    freeze
  end

  def find(id)
    @references[id]
  end

  def <<(id)
    new_node = Tree::TreeNode.new(id)
    super(new_node).tap { @references[id] = new_node }
  end

  def register_child(parent_id, child_id)
    @references[parent_id] << Tree::TreeNode.new(child_id).tap { |child_node| @references[child_id] = child_node }
  end

  def distance(id_a, id_b)
    return nil if @references[id_a].nil? || @references[id_b].nil?

    @references[id_a].distance_to_common_ancestor(@references[id_b])
  end

  def discomfort(id_a, id_b)
    return 0 if id_a == id_b
    return DEFAULT_DISCOMFORT if id_a.nil? || id_b.nil?

    @discomforts[uuid_to_int(id_a) + uuid_to_int(id_b)] || DEFAULT_DISCOMFORT
  end

  def default_discomfort(id_a, id_b)
    return 0 if id_a == id_b

    dist = distance(id_a, id_b)

    return DEFAULT_DISCOMFORT if dist.nil?

    Rational(dist, dist + 1)
  end

  def guest_count(invitation_id)
    @invitation_counts[invitation_id] || 0
  end

  private

  def invitation_counts
    @invitation_counts = Guest.where.not(invitation_id: nil).group(:invitation_id).count
  end

  def discomforts
    @discomforts ||= GroupAffinity.pluck(:group_a_id, :group_b_id,
                                         :discomfort).each_with_object({}) do |(id_a, id_b, discomfort), acc|
      acc[uuid_to_int(id_a) + uuid_to_int(id_b)] = discomfort
    end
  end

  def uuid_to_int(uuid)
    uuid.gsub('-', '').hex
  end

  def hydrate(group)
    group.children.each do |child|
      register_child(group.id, child.id)

      hydrate(child)
    end
  end
end
