# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

FactoryBot.define do
  factory :website do
    content { 'MyText' }
    wedding { nil }
    version { 'v2.0' }
    sequence(:domain) { |n| "example-#{n}.com" }
    pages { [{ slug: '', title: 'Home' }] }
  end
end
