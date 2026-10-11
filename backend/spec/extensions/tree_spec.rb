# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

module Tree
  RSpec.describe TreeNode do
    describe '#distance_to_common_ancestor' do
      def assert_distance(node1, node2, distance)
        aggregate_failures do
          expect(node1.distance_to_common_ancestor(node2)).to eq(distance)
          expect(node2.distance_to_common_ancestor(node1)).to eq(distance)
        end
      end
      context 'when the two nodes are the same' do
        it 'returns 0 when comparing the root itself' do
          root = described_class.new('root')
          assert_distance(root, root, 0)
        end

        it 'returns 0 when comparing a child to itself' do
          root = described_class.new('root')
          child = root << described_class.new('child')
          assert_distance(child, child, 0)
        end
      end

      context 'when the two nodes are siblings' do
        it 'returns 1 when comparing siblings' do
          root = described_class.new('root')
          child1 = root << described_class.new('child1')
          child2 = root << described_class.new('child2')
          assert_distance(child1, child2, 1)
        end
      end

      context 'when one node is parent of the other' do
        it 'returns 1 when comparing parent to child' do
          root = described_class.new('root')
          child = root << described_class.new('child')
          assert_distance(root, child, 1)
        end
      end

      context 'when one node is grandparent of the other' do
        it 'returns 2 when comparing grandparent to grandchild' do
          root = described_class.new('root')
          child = root << described_class.new('child')
          grandchild = child << described_class.new('grandchild')
          assert_distance(root, grandchild, 2)
        end
      end

      context 'when the two nodes are cousins' do
        it 'returns 2 when comparing cousins' do
          root = described_class.new('root')
          child1 = root << described_class.new('child1')
          child2 = root << described_class.new('child2')
          grandchild1 = child1 << described_class.new('grandchild1')
          grandchild2 = child2 << described_class.new('grandchild2')
          assert_distance(grandchild1, grandchild2, 2)
        end
      end

      context 'when the two nodes are not related' do
        it 'returns nil' do
          root = described_class.new('root')
          another_root = described_class.new('another_root')
          assert_distance(root, another_root, nil)
        end
      end
    end
  end
end
