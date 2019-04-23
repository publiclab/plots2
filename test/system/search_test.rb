require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class SearchTest < ApplicationSystemTestCase
    test 'searching an item from the homepage' do
      visit '/'
    
      fill_in("searchform_input", with: "Canon")
      find('button.btn-default').click
    
      assert_selector('h2', text: 'Results for Canon')
    end
end

class LoginSingUpTest < ApplicationSystemTestCase
    test 'sign up' do
      visit '/signup'
    
      assert_selector('h2', text: 'Sign up to join the Public Lab community')
    
      fill_in("username-signup", with: "Bob")
      fill_in("email", with: "bob@email.com")
    
      # The first argument to attach_file is a locator which refers to the name
      # attribute on the input tag.
      # attach_file("user[photo]", Rails.root + '/public/images/pl.png')
    
      fill_in("password", with: "Bob1234")
      fill_in("password-confirmation", with: "Bob1234")
    
      # Check the RECAPTCHA box
      # within_frame("a-fa3pgrq3s2ty") do
      #   check("recaptcha-anchor")
      # end
    
      # find('button.btn.btn-lg.btn-primary.btn-save').click
    
      # This method does not require defining a custom matcher.
      # expect(page).to have_selector(:link_or_button, 'Asking a question')
      # expect(page).to have_selector(:link_or_button, 'Exploring projects')
    
      # assert_selector('h2', text: 'Hello, welcome to Public Lab!')
    end
end

class QuestionTest < ApplicationSystemTestCase
    test 'view questions by topic' do
      visit '/questions'
    
      assert_selector('h4', text: 'View questions by topic')
      fill_in("taginput", with: "sensor")
      # expect(page).to have_content("sensor")
    
      find_button("View questions with the entered title").click
      
      # expect(page).to have_content("sensor")
      assert_selector('h3', text: 'Notes tagged with ')
    end

    test 'aske a question' do
      visit '/questions'
        
      assert_selector('h4', text: 'Ask a question here')
        
      fill_in("questions_searchform_input", with: "How do I change my username?")
      find_button("Ask a question with the entered title").click
      
      # --Redirect to another page with more details to fill in.
      # assert_selector('h2', text: 'Ask a question of the PublicLab community')
      
      # --Use selector to see if field is pre-filled with correct text.
      # expect(page).to have_selector("input[value='How do I change my username?']")
      
      # find('button.btn-horizontal.btn.btn-default').click
      # expects(page).to have_selector("hr")
      # find('button.btn-youtube.btn.btn-default').click
      # page.driver.browser.switch_to.alert.accept
      # --Communicate with the javascript prompt dialog.
      # expect(page). to have_selector("iframe[src='the_youtube_link']")
      
      # --Submit the question.
      # find('button.ple-publish.btn.btn-lg.btn-primary').click
      # --Pending approval.
      # expects(page).to have_selector("p[class='alert.alert-warning.moderated']")
      # expects(page).to have_content("Pending approval by")
    end
end
