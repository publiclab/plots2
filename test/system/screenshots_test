require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class SearchTest < ApplicationSystemTestCase
  test 'front page with navbar search autocomplete' do
    visit '/'

    fill_in("searchform_input", with: "Canon")
    
    # could try http://blog.mechanicles.com/2018/03/04/gotchas-rails-system-testing.html for "waiting"
    # or sleep(5.seconds)
    # or assert_select ".selector", wait: 5 # i think...
    # or https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara

    take_screenshot
    # we set RAILS_SYSTEM_TESTING_SCREENSHOT to 'inline', could be 'artifact' too... see Rails API guide
  end
end
