# frozen_string_literal: true

ActsAsTenant.current_tenant.locations.insert_all(
  3.times.map do
    {
      place_id: rand(5_000_000),
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      label: Faker::Address.city,
      display_name: Faker::Address.street_address
    }
  end
)
