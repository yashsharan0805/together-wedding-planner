# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    user { nil }
    wedding { nil }
    sequence(:confirmation_token) { "token_#{it}" }
  end
end
