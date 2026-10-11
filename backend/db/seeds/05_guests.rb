# frozen_string_literal: true

groups = Group.all

bus_options = [true, false]
menu_option_ids = ActsAsTenant.current_tenant.menu_option_ids
guest_params = NUMBER_OF_GUESTS.times.map do |i|
  {
    name: Faker::Name.name,
    group_id: groups.sample.id,
    status: Guest.statuses.keys.sample,
    menu_option_id: menu_option_ids.sample,
    menu_restrictions: ( "Allergic to #{Faker::Food.ingredient.downcase}" if (i % 10).zero?),
    needs_bus: bus_options.sample,
    special_requests: ( "A dose of #{Faker::Blood.group} just in case" if (i % 13).zero?)
  }
end

Guest.insert_all!(guest_params)
