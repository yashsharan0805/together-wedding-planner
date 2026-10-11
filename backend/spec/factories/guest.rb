# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

FactoryBot.define do
  factory :guest do
    name { Faker::Name.name }
    menu_restrictions { "Allergic to #{Faker::Food.allergen.downcase}" }
    transient do
      menu_choice { false }
    end

    after(:create) do |guest, context|
      guest.update!(menu_option: context.wedding.menu_options.find_by(name: context.menu_choice))
    end
  end
end
