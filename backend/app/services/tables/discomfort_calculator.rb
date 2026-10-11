# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

module Tables
  class DiscomfortCalculator
    attr_reader :table, :hierarchy

    def initialize(table:, hierarchy: AffinityGroupsHierarchy.new)
      @table = table
      @hierarchy = hierarchy
    end

    def calculate
      breakdown.values.sum
    end

    def breakdown
      @breakdown ||= { table_size_penalty:, cohesion_penalty:, invitations_penalty: }
    end

    private

    #
    # Calculates the penalty associated with violating the table size constraints. The penalty is
    # zero when the limits are honored, and it increases linearly as the number of guests deviates
    # from the limits. Overcapacity is penalized more severely than undercapacity.
    #
    # @return [Number] The penalty associated with violating the table size constraints.
    #

    def table_size_penalty
      case table.size
      when 0...table.min_per_table then 5 * (table.min_per_table - table.size)
      when table.min_per_table..table.max_per_table then 0
      else 5 * (table.size - table.max_per_table)
      end
    end

    def cohesion_penalty
      return 0 if table.empty?

      10 * (cohesion_discomfort * 1.0 / table.size)
    end

    def invitations_penalty
      2 * table.map(&:invitation_id)
               .tally
               .sum { |invitation_id, guests_in_table| hierarchy.guest_count(invitation_id) - guests_in_table }
    end

    #
    # Calculates the discomfort of the table based on the cohesion of the guests. The total discomfort
    # is calculated as the sum of the discomfort of each pair of guests. The discomfort of a pair of
    # guests is a rational number between 1 (unrelated groups) and 0 (same group).
    #
    # @return [Number] Total discomfort of the table.
    #

    def cohesion_discomfort
      table.map(&:group_id).tally.to_a.combination(2).sum do |(a, count_a), (b, count_b)|
        count_a * count_b * hierarchy.discomfort(a, b)
      end
    end
  end
end
