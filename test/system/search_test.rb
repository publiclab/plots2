require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class SearchTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'searching an item from the homepage' do
    visit '/'

    fill_in("searchform_input", with: "test")
    find('button.btn-light', match: :first).click

    title = find('.row h2', match: :first).text

    assert_equal "Search", title
    take_screenshot
  end

  test 'front page with navbar search autocomplete' do
    visit '/'

    fill_in("searchform_input", with: "test")

    typeahead_li = find('.typeahead .dropdown-item', match: :first).text

    assert_equal "test", typeahead_li

    take_screenshot

    assert page.evaluate_script("$('.typeahead.dropdown-menu').is(':visible')")
    assert_equal 4, page.evaluate_script("$('.typeahead.dropdown-menu').find('li').length")
  end
end
