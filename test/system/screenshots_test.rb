require "application_system_test_case"

class ScreenshotsTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'front page with navbar search autocomplete' do
    visit '/'
    fill_in("searchform_input", with: "Canon")
    assert_selector ".typeahead li", text: "Canon A1200 IR conversion at PLOTS Barnraising at LUMCON"
    take_screenshot
  end

  test 'wiki' do
    visit '/wiki'
    take_screenshot
  end

  test 'signup' do
    visit '/signup'
    take_screenshot
  end

  test 'login' do
    visit '/login'
    take_screenshot
  end

  test 'tags' do
    visit '/tags'
    take_screenshot
  end

  test 'tag/test' do
    visit '/tag/test'
    take_screenshot
  end

  test 'stats' do
    visit '/stats'
    take_screenshot
  end

  test 'blog' do
    visit '/blog'
    take_screenshot
  end

  test 'people' do
    visit '/people'
    take_screenshot
  end
end
