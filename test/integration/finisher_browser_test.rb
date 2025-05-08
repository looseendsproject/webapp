require "application_system_test_case"

class FinisherBrowserTest < ApplicationSystemTestCase
  test "register as finisher" do
    visit root_path

    assert_text "Volunteer as a Finisher"

    first(:link, "Sign Up").click

    assert_text "Already a finisher?"

    fill_in id: "user_first_name", with: "Test"
    fill_in id: "user_last_name", with: "User"
    fill_in id: "user_email", with: "testuser@example.com"
    select "Social Media", from: "heard-about-us-select"
    fill_in id: "user_password", with: "notagoodpassword"
    fill_in id: "user_password_confirmation", with: "notagoodpassword"
    click_button name: "commit"

    assert_text "Welcome! You have signed up successfully."
  end
end
