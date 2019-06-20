require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class SearchTest < ApplicationSystemTestCase
  test 'searching an item from the homepage' do
    visit '/'

    fill_in("searchform_input", with: "Canon")
    find('button.btn-light').click

    assert_selector('h2', text: 'Results for Canon')
  end
  
  test 'searching using navbar autocomplete' do
    visit '/'

    fill_in("searchform_input", with: "Kite")

    assert_selector ".typeahead li", text: "kites", wait: 10

    assert page.evaluate_script("$('.typeahead.dropdown-menu').is(':visible')")
    assert_equal 2, page.evaluate_script("$('.typeahead.dropdown-menu').find('li').length")
  end
end
