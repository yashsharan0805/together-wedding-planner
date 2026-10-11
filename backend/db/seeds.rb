# frozen_string_literal: true

# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

NUMBER_OF_GUESTS = ENV['NUMBER_OF_GUESTS']&.to_i || 40
puts "Running seeds file with #{NUMBER_OF_GUESTS} guests"

ActsAsTenant.without_tenant do
  # TODO: Fix foreign keys cascade deletion
  User.delete_all
  Doorkeeper::AccessToken.delete_all
  Doorkeeper::Application.delete_all
  Wedding.delete_all
  SolidQueue::Job.delete_all
end

ActsAsTenant.with_tenant(Wedding.create!(slug: :default)) do
  Dir['db/seeds/*'].map { it.sub('db/', '') }.each do |file|
    puts "~> Loading #{file}..."
    require_relative file
  end
end
