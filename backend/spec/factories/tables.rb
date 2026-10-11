# frozen_string_literal: true

FactoryBot.define do
  factory :table do
    sequence(:number)
    capacity { 8..10 }
  end
end
