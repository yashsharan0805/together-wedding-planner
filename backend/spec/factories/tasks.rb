# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    wedding
    sequence(:title) { |n| "Task ##{n}" }
  end
end
