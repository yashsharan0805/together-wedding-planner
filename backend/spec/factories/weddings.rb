# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

FactoryBot.define do
  factory :wedding do
    sequence(:slug) { |i| "wedding-#{i}" }
  end
end
