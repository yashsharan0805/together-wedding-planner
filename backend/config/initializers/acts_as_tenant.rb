# frozen_string_literal: true

# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

ActsAsTenant.configure do |config|
  config.require_tenant = lambda do
    return false unless Current.request_path
    return false if Current.request_path.start_with?('/jobs/')

    true
  end
end

Rails.application.console do
  ActsAsTenant.current_tenant = Wedding.first
end
