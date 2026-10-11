# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    wedding { nil }
    place_id { rand(5_000_000) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    label { Faker::Address.city }
    display_name { Faker::Address.street_address }
  end
end
