# frozen_string_literal: true

# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WeddingPlanner
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Use a real queuing backend for Active Job (and separate queues per environment).
    config.active_job.queue_adapter = :solid_queue

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: false,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       request_specs: false,
                       controller_specs: false
      g.orm :active_record, primary_key_type: :uuid
    end

    config.relative_url_root = '/api'

    config.generators.jbuilder = false

    config.silence_healthcheck_path = '/up'

    # Require superadmin flag to access mission control jobs UI
    config.mission_control.jobs.http_basic_auth_enabled = false
    config.mission_control.jobs.base_controller_class = 'SuperadminController'

    # Disable variant processing. Right now, attachments are used as they are,
    # we're not making any further processing
    config.active_storage.variant_processor = :disabled

    config.hosts << 'backend:3000'
  end

  def self.redis
    @redis ||= ConnectionPool::Wrapper.new do
      Redis.new(url: ENV.fetch('REDIS_URL', nil))
    end
  end
end
