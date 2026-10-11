# frozen_string_literal: true

class BusPriceOptimizer
  def initialize(prices)
    # TODO: Remove prices that charge more for fewer guests
    @prices = prices
    @acc = { 0 => {} }
  end

  def best_price(count)
    evaluate_solution(configuration(count))
  end

  def configuration(count)
    raise ArgumentError if count.negative?
    return @acc[count] if @acc.key?(count)

    @acc[count] ||= build_configuration_candidates(count).min_by { evaluate_solution(it) }
  end

  private

  def evaluate_solution(solution)
    solution.sum { |size, qty| @prices[size] * qty }
  end

  def build_configuration_candidates(count)
    candidates = []
    @prices.each_key do |size|
      if count <= size
        candidates << { size => 1 }
      else
        best_config = configuration(count - size).dup
        best_config[size] ||= 0
        best_config[size] += 1
        candidates << best_config
      end
    end

    candidates
  end
end
