# frozen_string_literal: true

FactoryBot.define do
  factory :engine_stat do
    sequence(:iteration)
    evaluation_count { rand(1000..1999) }
    real_time { rand }
    system_time { rand }
    user_time { rand }
    total_time { rand }
  end
end
