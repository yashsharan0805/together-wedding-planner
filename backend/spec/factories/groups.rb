# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    wedding
    sequence(:name) { |i| "Group #{i}" }
    order { 1 }
  end
end
