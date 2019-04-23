require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
  test "preserve return_to while switching from login to signup" do
    visit '/login?return_to=/subscribe/multiple/tag/tag1,tag2'
    click_on "sign up"
    assert_text "Create a password"
    assert_text "Confirmation"
    assert_text "Bio"
  end
end
