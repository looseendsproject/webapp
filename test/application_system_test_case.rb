# frozen_string_literal: true

require "test_helper"

# Capybara::Minitest::Assertions doco
# https://rubydoc.info/gems/capybara/Capybara/Minitest/Assertions

# Cheatsheet: https://devhints.io/capybara

# Locators: https://www.selenium.dev/documentation/webdriver/elements/locators/
  # XPath: https://www.geeksforgeeks.org/introduction-to-xpath/

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
