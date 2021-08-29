require "application_system_test_case"

class TranslationUiTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'translation change screenshot' do
  	visit '/'

  	take_screenshot
  end

end