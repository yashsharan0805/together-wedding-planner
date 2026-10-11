# frozen_string_literal: true

ActsAsTenant.current_tenant.website.update!(
  version: 'v2.0',
  pages: [
    {
      slug: '',
      title: "#{Faker::Name.first_name} & #{Faker::Name.first_name}",
      title_font_family: 'Monsieur La Doulaise',
      subtitle: "#{Date.tomorrow} · #{Faker::Address.city}"
    },
    {
      slug: 'transport',
      title: 'Transport',
      title_font_family: 'Cinzel',
      content: <<~MD
        These are the best options to get to the venue:

        1. By *plane*
        1. By *train* although it takes _significantly_ longer

        If you want to get in touch with other people interested in renting a car, please reach out to us.
      MD
    },
    {
      slug: 'schedule',
      title: 'Schedule',
      title_font_family: 'Cinzel',
      content: <<~MD
        Here is the approximate schedule for the event. Don't be late!
        - 11.00 Bus pickup at Big Square
        - 12.00 Welcoming at the venue
        - 12.30 Ceremony
        - 13.30 Cocktail
        - 16.00 Banquet
        - 18.00 Party!
        - 23.30 Bus pickup at the venue
        - 00.15 Bus drop-off
      MD
    }
  ]
)
