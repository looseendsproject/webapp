# frozen_string_literal: true

require "test_helper"

# Capybara::Minitest::Assertions doco
# https://rubydoc.info/gems/capybara/Capybara/Minitest/Assertions

# Cheatsheet: https://devhints.io/capybara

# Locators: https://www.selenium.dev/documentation/webdriver/elements/locators/
# XPath: https://www.geeksforgeeks.org/introduction-to-xpath/

Capybara.configure do |config|
  config.save_path = Rails.root.join("tmp/screenshots")
  config.always_include_port = true
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400], options: {
    browser: :remote, url: "http://selenium:4444"
  }
  include Devise::Test::IntegrationHelpers
end
