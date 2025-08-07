# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase

  test "options_for_check_in_interval_select returns proper struct" do
    assert_equal [
      ["3 weeks (default)", nil], ["4 weeks", 4], ["5 weeks", 5],
      ["6 weeks", 6], ["7 weeks", 7], ["8 weeks", 8]
    ], options_for_check_in_interval_select
  end
end
