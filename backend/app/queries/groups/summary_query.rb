# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

module Groups
  class SummaryQuery
    def call
      Group.left_joins(:guests).group(:id).pluck_to_hash(
        :id,
        :name,
        :icon,
        :parent_id,
        :color,
        *count_expressions
      )
    end

    private

    def count_expressions
      [
        Arel.sql('count(*) filter (where status IS NOT NULL) as total'),
        Arel.sql('count(*) filter (where status = 0) as considered'),
        Arel.sql('count(*) filter (where status = 10) as invited'),
        Arel.sql('count(*) filter (where status = 20) as confirmed'),
        Arel.sql('count(*) filter (where status = 30) as declined'),
        Arel.sql('count(*) filter (where status = 40) as tentative')
      ]
    end
  end
end
