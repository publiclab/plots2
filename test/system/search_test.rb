require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class SearchTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'searching an item from the homepage' do
    visit '/'

    fill_in("searchform_input", with: "Canon")
    find('button.btn-light').click

    assert_selector('h2', text: 'Search')
  end

  test 'front page with navbar search autocomplete' do
    visit '/'

    fill_in("searchform_input", with: "test")
    
    assert_selector ".typeahead li", text: "test"

    take_screenshot

    assert page.evaluate_script("$('.typeahead.dropdown-menu').is(':visible')")
    assert_equal 6, page.evaluate_script("$('.typeahead.dropdown-menu').find('li').length")
  end
end
