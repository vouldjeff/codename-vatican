ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__) unless defined?(Rails)
require 'rspec/rails'

require File.dirname(__FILE__) + "/factories"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # config.before(:each) { Machinist.reset_before_test }
  
  config.mock_with :rspec
end
