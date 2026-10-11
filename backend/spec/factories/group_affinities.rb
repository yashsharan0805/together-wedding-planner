# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

FactoryBot.define do
  factory :group_affinity do
    group_a factory: %i[group]
    group_b factory: %i[group]
    discomfort { GroupAffinity::NEUTRAL }
  end
end
