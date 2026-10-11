# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

FactoryBot.define do
  factory :expense do
    wedding
    sequence(:name) { |i| "Expense #{i}" }
    pricing_type { 'fixed' }
    amount { 100 }
  end

  trait :fixed do
    pricing_type { 'fixed' }
  end

  trait :per_person do
    pricing_type { 'per_person' }
  end
end
