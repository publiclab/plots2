require 'application_system_test_case'

class NoteTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'clicking tabs in notes by author page' do
  visit 'notes/author/bob'

  find('.nav-link', text: 'Research Notes').click()
  page.assert_selector('.nav-link active', text: 'Research Notes')

  find('.nav-link', text: 'Questions').click()
  page.assert_selector('.nav-link active', text: 'Questions')

  find('.nav-link', text: 'Wiki pages').click()
  page.assert_selector('.nav-link active', text: 'Wiki pages')

  find('.nav-link', text: 'Comments').click()
  page.assert_selector('.nav-link active', text: 'Comments')
  end
end