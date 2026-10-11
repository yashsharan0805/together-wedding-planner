# frozen_string_literal: true

class CapacityValidator < ActiveModel::Validator
  def validate(record) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    capacity = record.capacity

    return if capacity.blank?

    record.errors.add(:capacity, 'must be a Range') and return unless capacity.is_a?(Range)
    record.errors.add(:capacity, 'must have a lower bound') and return if capacity.begin.nil?
    record.errors.add(:capacity, 'must have an upper bound') and return if capacity.end.nil?
    record.errors.add(:capacity, 'lower bound must be positive') and return unless capacity.begin.positive?
    unless capacity.begin.is_a?(Integer) && capacity.end.is_a?(Integer)
      record.errors.add(:capacity, 'bounds must be integers') and return
    end

    return unless capacity.begin && capacity.end && capacity.end < capacity.begin

    record.errors.add(:capacity, 'upper bound must be greater than or equal to lower bound')
  end
end
