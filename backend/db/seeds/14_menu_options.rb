# frozen_string_literal: true

ActsAsTenant.current_tenant.menu_options.insert_all(
  rand(3..5).times.map { { name: Faker::Food.dish } }
)
