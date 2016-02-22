require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
#require '../app/middlewares/chat_backend.rb'


# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module RailsOnForum
  class Application < Rails::Application

    config.to_prepare do
      # Load application's model / class decorators
      Dir.glob(File.join(File.dirname(__FILE__), "../app/middlewares/chat_backend.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
     # config.middleware.use ChatDemo::ChatBackend
    #config.action_view.default_form_builder = FoundationFormBuilder::Rails
    #config.autoload_paths += %W(#{config.root}/app/models/ckeditor)
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

     config.action_controller.asset_host = 'http://www.trade-v.com:5000/'
    #config.assets.prefix = "/foodiegroup/assets"
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :zh

    #for rspec
    config.generators do |g|
      g.tset_framework :rspec,
      fixtures: true,
      view_specs: false,
      helper_specs: false,
      routing_specs: false,
      controller_specs: true,
      requeset_specs: false
      g.fixture_replacement :factory_girl, dir: 'specs/factories'
    end

  end
end
