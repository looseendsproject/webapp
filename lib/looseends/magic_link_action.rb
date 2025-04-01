# frozen_string_literal: true

# See Message#link_action
#
# On a magic link click, what do we do next?
# message.link_action a JSON serialized array like "[\"redirect_to\",\"/finisher/new\"]"
# that string is used by Users::SessionsController#magic_link
# which does `redirect_to Looseends::MagicLinkActions.send(link_action)`
#
# The SGID this way can do a whole lot of things before the redirect,
# and the controller doesn't have to know about it.
#
# Every method needs to return a path that SessionsController will use
# for redirect.
#
module Looseends
  class MagicLinkAction
    class ToDo < StandardError; end

    class << self

      # ['reflect', 'param1', 'param2', 'user_input'...]
      # used for testing
      def reflect(*args)
        args
      end

      # ['redirect_to', '/finisher/new']
      def redirect_to(path)
        path
      end

      # ['update_project_status', 'bad']
      def update_project_status(status)
        raise ToDo
      end

    end # class methods

  end
end
