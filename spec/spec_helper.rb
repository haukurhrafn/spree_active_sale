require 'simplecov'
SimpleCov.start do
  add_filter 'spec/dummy'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Models', 'app/models'
  add_group 'Views', 'app/views'
  add_group 'Libraries', 'lib'
end

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'database_cleaner'
require 'capybara/rspec'
require 'capybara/rails'
require 'shoulda/matchers'
require 'ffaker'
require 'factory_girl'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

# Requires factories defined in spree_core
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/factories'
require 'spree/testing_support/preferences'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/flash'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/order_walkthrough'
require 'spree/testing_support/caching'
require 'spree/testing_support/shoulda_matcher_configuration'
require 'spree/testing_support/microdata'
require 'paperclip/matchers'

# require 'byebug'
require 'spree_active_sale/factories'

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:each) do
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
    reset_spree_preferences
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include FactoryGirl::Syntax::Methods

  # == URL Helpers
  #
  # Allows access to Spree's routes in specs:
  #
  # visit spree.admin_path
  # current_path.should eql(spree.products_path)
  config.include FactoryGirl::Syntax::Methods

  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include Spree::TestingSupport::Flash
  config.include Paperclip::Shoulda::Matchers

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.expose_current_running_example_as :example
  config.infer_spec_type_from_file_location!


  config.color = true
  config.fail_fast = ENV['FAIL_FAST'] || false
  config.fixture_path = File.join(File.expand_path(File.dirname(__FILE__)), "fixtures")
  config.mock_with :rspec
  config.raise_errors_for_deprecations!

end

RSpec::Matchers.define :have_valid_factory do |factory_name|
  match do |model|
    Factory(factory_name).new_record?.should be_false
  end
end
