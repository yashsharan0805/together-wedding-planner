# frozen_string_literal: true

class PositionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, 'Must be a Point') and return unless value.is_a?(ActiveRecord::Point)

    record.errors.add(attribute, 'X and Y must be non-negative numbers') if [value.x, value.y].any?(&:negative?)
  end
end
