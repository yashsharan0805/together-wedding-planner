# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

module TreeNodeExtension
  def distance_to_common_ancestor(another_node)
    return 0 if self == another_node

    my_path = path_as_array
    another_path = another_node.path_as_array

    common_elements = my_path.zip(another_path)
                             .take_while { |(p1, p2)| p1 == p2 }
                             .count

    return nil if common_elements.zero?

    [my_path.count, another_path.count].max - common_elements
  end
end

Tree::TreeNode.include(TreeNodeExtension)
