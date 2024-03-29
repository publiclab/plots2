require "application_system_test_case"

class SignupFormTest < ApplicationSystemTestCase
  def setup
    visit "/"
  end
  
  test "the signup form is validated and rejects duplicate email and username" do 
    visit "/signup" 
       
    assert_difference 'User.count', 0 do
      # Signs up with an already-registered email 
      fill_in("username-signup", with: "abc") 
      fill_in("email", with: "jeff@pxlshp.com") 
      fill_in("password1", with: "secretive") 
      fill_in("password-confirmation", with: "secretive") 
      find("#create-form #signup-button").click() 
    end

    assert_difference 'User.count', 0 do
      # Signs up with an already-registered username 
      fill_in("username-signup", with: "jeff") 
      fill_in("email", with: "random@publiclab.com") 
      fill_in("password1", with: "secretive") 
      fill_in("password-confirmation", with: "secretive")    
      find("#create-form #signup-button").click() 
    end
  end

  test "javascript I18njs translation helper working" do
    assert_selector('.navbar-brand') # ensure page is loaded
    helper_output = page.evaluate_script("I18n.t('users._form.confirm_password')")
    assert_equal helper_output, "Retype your password to confirm"
  end
end
