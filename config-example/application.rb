require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module InfrastructureDb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Avoid deprecation warning after rails 4.0.2 update.
    I18n.config.enforce_available_locales = true
    config.i18n.fallbacks = [I18n.default_locale]

    #config.action_mailer.perform_deliveries = Rails.env.production?
    #config.action_mailer.raise_delivery_errors = true
    #config.action_mailer.delivery_method = :sendmail

    config.action_mailer.delivery_method = :test
    config.action_mailer.delivery_method = :file
    config.action_mailer.file_settings = { :location => Rails.root.join('tmp/mail') }

    config.active_record.yaml_column_permitted_classes = [Symbol]
  end
end
