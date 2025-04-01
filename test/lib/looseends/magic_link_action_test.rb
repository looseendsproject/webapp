# frozen_string_literal: true

require "test_helper"

module Looseends
  class MagicLinkActionTest < ActiveSupport::TestCase

    test "reflection" do
      # Only stored params
      link_action = JSON.generate(["reflect", "/finisher/new"])
      send_params = JSON.parse(link_action)
      assert_equal [send_params.second], Looseends::MagicLinkAction.send(*send_params)

      # Only request params
      link_action = JSON.generate(['reflect'])
      req_params = %w(param1 param2 param3)
      send_params = JSON.parse(link_action) + req_params
      assert_equal req_params, Looseends::MagicLinkAction.send(*send_params)

      # With a mix of stored and request params
      link_action = JSON.generate(['reflect', 'stored_param'])
      req_params = %w(user_param1 user_param2 user_param3)
      send_params = JSON.parse(link_action) + req_params
      assert_equal [JSON.parse(link_action).last] + req_params,
        Looseends::MagicLinkAction.send(*send_params)
    end

    test "redirect_to" do
      link_action = JSON.generate(["redirect_to", "/finisher/new"])
      params = JSON.parse(link_action)
      assert_equal params.second, Looseends::MagicLinkAction.send(*params)
    end

    test "update_project_status" do
      link_action = JSON.generate(%w(update_project_status true))
      params = JSON.parse(link_action)
      assert_raises(Looseends::MagicLinkAction::ToDo) do
        Looseends::MagicLinkAction.send(*params)
      end
    end

  end
end
