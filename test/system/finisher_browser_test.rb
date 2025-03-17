require "application_system_test_case"

class FinisherBrowserTest < ApplicationSystemTestCase
  test 'register as finisher' do
    visit root_path
    assert_text "Why it’s important to finish a handmade project"

    first(:link, 'Sign Up').click
    assert_text "If you are already a finisher, do this..."

    fill_in id: 'user_first_name', with: 'Test'
    fill_in id: 'user_last_name', with: 'User'
    fill_in id: 'user_email', with: 'testuser@example.com'
    select 'Instagram', from: 'heard-about-us-select'
    fill_in id: 'user_password', with: 'notagoodpassword'
    fill_in id: 'user_password_confirmation', with: 'notagoodpassword'
    click_button name: 'commit'
    assert_text "Welcome! You have signed up successfully."
  end
end
