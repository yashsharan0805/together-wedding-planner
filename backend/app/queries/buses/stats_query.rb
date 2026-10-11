# frozen_string_literal: true

module Buses
  class StatsQuery
    delegate :confirmed, :potential, to: :result

    private

    def result
      @result ||= Guest.potential.where(needs_bus: true)
                       .select('count(*) as potential')
                       .select("count(*) filter(where status=#{Guest.statuses[:confirmed].to_i}) as confirmed")[0]
    end
  end
end
