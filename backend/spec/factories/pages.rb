# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    sequence(:slug) { |i| "page-#{i}" }
    title { Faker::Marketing.buzzwords }
    content { Faker::Markdown.emphasis }
    title_font_family { 'Monsieur La Doulaise' }
  end
end
