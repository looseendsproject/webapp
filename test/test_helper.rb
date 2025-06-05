# frozen_string_literal: true

ENV["WD_CHROMEDRIVER_PATH"] = "/usr/bin/chromedriver"

require 'webdrivers'

# Set a very long cache time so it rarely tries to update
Webdrivers.cache_time = 86_400 * 365 # 1 year in seconds

# Optionally force it to think the chromedriver version is correct
# by setting required_version to the installed version string
# (Run `chromedriver --version` in your container and replace "XX.XX.XX")
Webdrivers::Chromedriver.required_version = "114.0.5735.90" # example version

# You can also try to silence update checking by monkeypatching (last resort)
module Webdrivers
  class Chromedriver
    def self.update
      # no-op disables update attempts
    end
  end
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "capybara/rails"
require "capybara/minitest"

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    Geocoder.configure(lookup: :test)
    # Locations form test fixtures
    Geocoder::Lookup::Test.add_stub(
      "123 Main St, Anytown, WA, 12345", [{
        "latitude" => 40.7143528,
        "longitude" => -74.0059731,
        "address" => "New York, NY, USA",
        "state" => "New York",
        "state_code" => "NY",
        "country" => "United States",
        "country_code" => "US"
      }]
    )

    # needed one with the "US" at the end
    Geocoder::Lookup::Test.add_stub(
      "123 Main St, Anytown, WA, 12345, US", [{
        "latitude" => 40.7143528,
        "longitude" => -74.0059731,
        "address" => "New York, NY, USA",
        "state" => "New York",
        "state_code" => "NY",
        "country" => "United States",
        "country_code" => "US"
      }]
    )
  end
end

module ActionController
  class TestCase
    include Devise::Test::ControllerHelpers
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end

def setup_message!
  content = File.read(Rails.root.join("test/fixtures/files/sample_2.eml"))
  Message.all.map { |m| m.update!(content: content) }
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,1400")

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.javascript_driver = :headless_chrome

class ActionDispatch::SystemTestCase
  include Capybara::DSL

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
