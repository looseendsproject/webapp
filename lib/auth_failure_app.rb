# frozen_string_literal: true

class AuthFailureApp < Devise::FailureApp
  def route(_scope)
    :new_user_registration_url
  end
end
