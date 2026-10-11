# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    transient do
      wedding { nil } # Expects passing wedding to the user factory
    end
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123456789' }
    password_confirmation { 'password123456789' }
    confirmed_at { Time.current }

    after(:create) do |user, context|
      create(:membership, user:, wedding: context.wedding, confirmed_at: 1.hour.ago)
    end
  end
end
