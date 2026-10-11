# frozen_string_literal: true

FactoryBot.define do
  factory :settings do
    date { Time.zone.today + 30.days }
  end
end
