# frozen_string_literal: true

FactoryBot.define do
  factory :bus_quote do
    wedding
    bus_trip
    sequence(:company) { |n| "Bus Company #{n}" }
    prices { {} }
  end
end
