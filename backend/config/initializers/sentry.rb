
if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV.fetch("SENTRY_DSN")
    config.traces_sample_rate = Rails.env.development? ? 1 : 0.01 # 1% of transactions
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  end
end