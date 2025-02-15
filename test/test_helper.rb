# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    Geocoder.configure(lookup: :test)
    # Locations form test fixtures
    Geocoder::Lookup::Test.add_stub(
      "123 Main St, , Anytown, WA, 12345", [{
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
      "123 Main St, , Anytown, WA, 12345, US", [{
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
