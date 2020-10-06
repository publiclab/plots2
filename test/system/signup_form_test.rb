require "application_system_test_case"

class SignupFormTest < ApplicationSystemTestCase
    def setup
      visit "/"
    end
  
    test "the signup form is validated" do 
        visit "/signup" 
       
        assert_difference 'User.count', 0 do
            # Signs up with an already-registered email 
            fill_in("username-signup", with: "abc") 
            fill_in("email", with: "jeff@pxlshp.com") 
            fill_in("password1", with: "secretive") 
            fill_in("password-confirmation", with: "secretive") 
        
            find("#create-form #signup-button").click() 
        end
    end 
end
