require "application_system_test_case"

class ManagerBrowserTest < ApplicationSystemTestCase
  def setup
    visit '/users/sign_in'
    fill_in id: 'user_email', with: users(:admin).email
    fill_in id: 'user_password', with: 'badpassword'
    click_link_or_button 'Log in'
    assert_text "Signed in successfully."
    click_link "Manage"
    assert_text "Dashboard"
  end

  test 'browse projects' do
    click_link "Finishers"
    # TODO
  end

  test 'browse finishers' do
  end
end
