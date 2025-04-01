# frozen_string_literal: true

require "test_helper"

module Looseends
  class MagicLinkActionTest < ActiveSupport::TestCase

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
