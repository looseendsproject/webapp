require "application_system_test_case"

class ManagerBrowserTest < ApplicationSystemTestCase
  def setup
    visit '/users/sign_in'
    fill_in id: 'user_email', with: users(:admin).email
    fill_in id: 'user_password', with: 'badpassword'
    click_link_or_button 'Log in'
    assert_text "Signed in successfully."
    visit "/manage"
  end

  def teardown
    click_link "Sign Out"
  end

  test "dashboard widgets" do
    assert_text "Dashboard"
    assert_text "Failed Inbound Emails"
    assert_text "Reports"
    assert_text "New scheduled job logs"
  end

  test 'browse projects' do
    click_link "Projects"
    assert_text "Projects"
  end

  test 'browse finishers' do
    click_link "Finishers Search"
    assert_text "Finishers"
  end

  test "view reports" do
    click_link "Reports"
    assert_text "Other Reports"
  end
end
