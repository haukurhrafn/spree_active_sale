# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
# require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'ffaker'
require 'spree/testing_support/factories'
require 'spree/testing_support/controller_requests.rb'
require 'spree/testing_support/preferences.rb'
require 'spree/testing_support/authorization_helpers.rb'
require 'spree/api/testing_support/helpers'
require 'spree/api/testing_support/caching'
require 'spree/api/testing_support/setup'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/factories'
require 'spree/testing_support/preferences'

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.backtrace_exclusion_patterns = [/gems\/activesupport/, /gems\/actionpack/, /gems\/rspec/]
  config.color = true
  config.fail_fast = ENV['FAIL_FAST'] || false
  config.raise_errors_for_deprecations!
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.include Spree::TestingSupport::Preferences
  config.include Spree::Core::Engine.routes.url_helpers
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include Spree::Api::TestingSupport::Helpers, :type => :controller
  config.extend Spree::Api::TestingSupport::Setup, :type => :controller
  config.include Spree::TestingSupport::Preferences, :type => :controller
  config.include FactoryGirl::Syntax::Methods

  config.before do
    Spree::Api::Config[:requires_authentication] = true
  end


end

Paperclip.options[:command_path] = "/usr/local/bin/identify"
