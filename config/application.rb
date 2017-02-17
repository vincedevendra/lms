require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Lms
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.active_record.default_timezone = :local
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :sidekiq

    config.assets.enabled = true
    config.assets.precompile += %w( bootstrap-clockpicker.min.js )

    config.autoload_paths += %W(#{config.root}/lib)
    config.generators do |g|
      g.orm :active_record
      g.template_engine :haml
    end
  end
end
