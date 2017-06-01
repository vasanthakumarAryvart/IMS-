ENV['TZ'] = 'CT'

require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require 'rails/all'
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Clarabyte
  class Application < Rails::Application

     config.action_dispatch.default_headers.merge!({
    'Access-Control-Allow-Origin' => '*',
    'Access-Control-Request-Method' => '*'
    })
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.eager_load_paths += Dir["#{config.root}/lib/**/"]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.redis_url = ENV['REDIS_URL'] || YAML.load(File.open('config/redis.yml'))[Rails.env]
    config.cache_store = :redis_store, config.redis_url
    config.active_record.raise_in_transactional_callbacks = true
    # config.middleware.use Rack::Cors do
    #     allow do
    #         origins '*'
    #         resource '*',
    #         :headers => :any,
    #         :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
    #         :methods => [:get, :post, :options, :delete, :put]
    #     end
    # end
    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*', 
            :headers => :any, 
            :methods => [:get, :post, :patch, :delete, :put, :options]
      end
    end


  end
end
