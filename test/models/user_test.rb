# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase

  test "user has messages" do
    assert_nothing_raised { User.first.messages }
  end
end
