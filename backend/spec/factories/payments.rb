# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    sequence(:title) { |n| "Payment #{n}" }
    amount { 100.0 }
  end
end
