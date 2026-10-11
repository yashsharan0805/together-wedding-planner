# frozen_string_literal: true

ActsAsTenant.current_tenant.settings.update!(
  date: Time.zone.today + 30.days,
  bus_management: true
)
ActsAsTenant.current_tenant.settings.invitation_config.update!(
  qr_position: [670, 445],
  qr_color: '#343434',
  qr_fill_color: nil,
  qr_size_px: 250,
  text_position: [200, 450],
  text_font_family: 'Arial',
  text_color: '#4E342E',
  text_font_size: 35,
  text_font_weight: 500,
  text_align: :center
)
