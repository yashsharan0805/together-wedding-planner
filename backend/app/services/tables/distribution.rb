# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require_relative '../../extensions/tree_node_extension'

module Tables
  class DistributionError < StandardError; end

  class Distribution
    class << self
      def load(tables_arrangement_id)
        tables_arrangement = TablesArrangement.find(tables_arrangement_id)

        distribution = new(tables_arrangement_id:)

        tables_arrangement.tables.includes(seats: :guest).find_each do |table|
          guests = table.seats.map { |seat| seat.guest.tap { |guest| guest.pinned = seat.pinned? } }
          new_table = Table.new(guests)
          new_table.min_per_table, new_table.max_per_table = table.capacity.minmax
          new_table.name = table.name
          new_table.number = table.number
          distribution.tables << new_table
        end

        distribution
      end
    end

    attr_accessor :tables, :table_types, :hierarchy, :tables_arrangement_id

    def initialize(tables_arrangement_id:, table_types: nil, hierarchy: AffinityGroupsHierarchy.new)
      @table_types = table_types || ActsAsTenant.current_tenant.table_types.to_a
      @hierarchy = hierarchy
      @tables = []
      @tables_arrangement_id = tables_arrangement_id
      @rotation = @table_types.map(&:dup).cycle
    end

    def discomfort
      @tables.map do |table|
        local_discomfort(table)
      end.sum
    end

    def inspect
      "#{@tables.count} tables, discomfort: #{discomfort}"
    end

    def deep_dup
      self.class.new(
        table_types: @table_types,
        hierarchy: @hierarchy,
        tables_arrangement_id: @tables_arrangement_id
      ).tap do |new_distribution|
        new_distribution.tables = @tables.map(&:dup)
      end
    end

    private

    def validate_capacity!(count:)
      maximum_capacity = table_types.map { it.capacity.max * (it.availability || Float::INFINITY) }.sum
      raise DistributionError, 'Insufficient table capacity' if count > maximum_capacity
    end

    def insert_all_seats!
      table_id_mapping = arrangement.tables.reload.pluck(:number, :id).to_h

      records_to_store = []

      tables.each_with_index do |table, index|
        table.each do |person|
          records_to_store << {
            guest_id: person.id,
            tables_arrangement_id: arrangement.id,
            table_id: table_id_mapping[index + 1],
            pinned: !!person.pinned # rubocop:disable Style/DoubleNegation
          }
        end
      end

      Seat.insert_all!(records_to_store)
    end

    def arrangement
      @arrangement ||= TablesArrangement.find(tables_arrangement_id)
    end

    def delete_existing_records!
      arrangement.tables.delete_all # seats are removed on cascade
    end

    def create_activerecord_tables!
      table_attributes = tables.each_with_index.map do |table, index|
        {
          wedding_id: arrangement.wedding_id,
          tables_arrangement_id: arrangement.id,
          capacity: Range.new(table.min_per_table, table.max_per_table),
          name: table.name,
          number: index + 1
        }
      end
      ::Table.insert_all!(table_attributes)
    end

    def local_discomfort(table)
      table.discomfort ||= DiscomfortCalculator.new(table:, hierarchy:).calculate
    end
  end
end
