require "application_system_test_case"

class SignupFormTest < ApplicationSystemTestCase
  def setup
    visit "/"
  end

  test "the signup form is validated on page reload" do
    visit "/signup"

    #Signs up with registered email
    fill_in("username-signup", with: "abc")
    fill_in("email", with: "jeff@pxlshp.com")
    fill_in("password1", with: "secretive")
    fill_in("password-confirmation", with: "secretive")

    find("#create-form #signup-button").click()
    path = URI.parse(current_url).request_uri
    assert_equal path, "/register"
    #Searches for error
    assert_selector("#error-message #errorExplanation", text: "Email")

    fill_in("username-signup", with: "abc")
    fill_in("email", with: "abc@publiclab.org")
    fill_in("password1", with: "secretive")
    fill_in("password-confirmation", with: "secretive")
    #Checks if submit button is enabled
    find_button("signup-button")
  end
end
