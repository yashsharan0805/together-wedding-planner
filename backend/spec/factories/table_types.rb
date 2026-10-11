# frozen_string_literal: true

FactoryBot.define do
  factory :table_type do
    capacity { 8..10 }
    availability { nil }
  end
end
