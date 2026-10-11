# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

module CostCenters
  class StatsQuery
    def call
      Payment.left_joins(:cost_center)
             .group(:cost_center_id, 'cost_centers.name')
             .order('cost_centers.name ASC NULLS FIRST')
             .pluck_to_hash(
               Arel.sql('cost_centers.name as name'),
               Arel.sql('count(*) as count'),
               Arel.sql('sum(amount) as sum')
             ).to_a
    end
  end
end
