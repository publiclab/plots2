require "application_system_test_case"

class SignupFormTest < ApplicationSystemTestCase
  def setup
    visit "/"
  end

  test "the user is not registered without passing spam " do
    visit "/signup"

    assert_difference 'User.count', 0 do
        #Creating a user and leaving the spamaway check empty
        fill_in("username-signup", with: "abc")
        fill_in("email", with: "abc@publiclab.org")
        fill_in("password1", with: "secretive")
        fill_in("password-confirmation", with: "secretive")

        find("#create-form #signup-button").click()
    end

  end
end