
require "application_system_test_case"

# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class SearchTest < ApplicationSystemTestCase
  test 'search autocomplete' do
    # Visit the index page
    visit '/'

    fill_in "searchform_input", with: "Canon"
    # should return: nodes(:one)

    assert_selector "li", text: "TAGS"

  end
end
