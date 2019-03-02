require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class SearchTest < ApplicationSystemTestCase
  test 'search autocomplete' do
    visit '/'

    fill_in("searchform_input", with: "Canon")
    find('button.btn-default').click

    assert_selector('h2', text: 'Results for Canon')
  end
end
