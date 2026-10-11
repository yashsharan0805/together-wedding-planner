# frozen_string_literal: true

FactoryBot.define do
  factory :bus_trip do
    wedding
    sequence(:name) { |n| "Bus Trip #{n}" }
  end
end
