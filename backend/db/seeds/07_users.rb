# frozen_string_literal: true

User.create!(
  email: 'development@example.com',
  confirmed_at: Time.zone.now,
  password: 'supersecretpassword',
  password_confirmation: 'supersecretpassword',
  superadmin: true
).memberships.create!(wedding: ActsAsTenant.current_tenant, confirmed_at: 1.week.ago)

User.create!(
  email: 'foo@example.com',
  confirmed_at: Time.zone.now,
  password: 'supersecretpassword',
  password_confirmation: 'supersecretpassword',
  superadmin: false
).memberships.create!(
  wedding: ActsAsTenant.current_tenant,
  confirmation_token: SecureRandom.alphanumeric(60),
  confirmation_token_expires_at: 1.week.ago
)

User.create!(
  email: 'bar@example.com',
  confirmed_at: Time.zone.now,
  password: 'supersecretpassword',
  password_confirmation: 'supersecretpassword',
  superadmin: false
).memberships.create!(
  wedding: ActsAsTenant.current_tenant,
  confirmation_token: SecureRandom.alphanumeric(60),
  confirmation_token_expires_at: 1.week.from_now
)
