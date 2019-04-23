require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "preserve return_to while switching from login to signup" do
    visit '/login?return_to=/subscribe/multiple/tag/tag1,tag2'
    click_on "sign up"
    assert_redirected_to '/signup?return_to=/subscribe/multiple/tag/tag1,tag2'
    assert_text "Create a password"
    assert_text "Confirmation"
    assert_text "Bio"
  end
end
