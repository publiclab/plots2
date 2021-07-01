require 'application_system_test_case'

class NoteTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'there is an active tab in the notes by author page' do
  visit(notes_author_path('jeff'))

  page.assert_selector('.nav-link.active', text: 'Research Notes')
  end
end
