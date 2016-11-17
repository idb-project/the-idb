require 'raven'

Raven.configure do |config|
  config.dsn = 'https://dnsuid@sentryserver.example.com/2'
  config.timeout = 10
  config.logger = Rails.logger
  config.ssl_verification = false
  config.environments = %w[ production ]
end
