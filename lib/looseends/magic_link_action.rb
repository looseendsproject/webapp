# frozen_string_literal: true

# See Message#link_action
#
# On a magic link click, what do we do next?
# message.link_action is a JSON serialized array like "[\"redirect_to\",\"/finisher/new\"]"
# that string is used by Users::SessionsController#magic_link
# which does `redirect_to Looseends::MagicLinkActions.send(link_action)`
#
# If redirect is all that necessary, just store the path: "/finisher/new"
#   (see Message#send_link_action!)
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
      #
      def reflect(*args)
        args
      end

      # ['redirect_to', '/finisher/new']
      # (if this is all you want to do, just persist "/finisher/new" --
      #   see message.rb)
      #
      def redirect_to(path)
        path
      end

      # ['update_project_status', 'bad']
      #
      def update_project_status(status)
        # add ProjectNote & update last_contacted_at
        # send path for post-click
        raise ToDo
      end

    end # class methods

  end
end
