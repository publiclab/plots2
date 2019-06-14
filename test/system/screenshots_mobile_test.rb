require "application_system_test_case"

class ScreenshotsMobileTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  # iphone 6 screen width in points: https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
  chromeOptions = %w(--headless  --disable-gpu --no-sandbox --remote-debugging-port=9222)
  caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => chromeOptions})
  driven_by :selenium, using: :chrome, screen_size: [375, 1400], options: { desired_capabilities: caps }

  test 'front page with navbar search autocomplete mobile' do
    visit '/'
    fill_in("searchform_input", with: "Canon")
    assert_selector ".typeahead li", text: "Canon A1200 IR conversion at PLOTS Barnraising at LUMCON"
    take_screenshot
  end

  test 'wiki mobile' do
    visit '/wiki'
    take_screenshot
  end

  test 'signup mobile' do
    visit '/signup'
    take_screenshot
  end

  test 'login mobile' do
    visit '/login'
    take_screenshot
  end

  test 'tags mobile' do
    visit '/tags'
    take_screenshot
  end

  test 'tag page mobile' do
    visit '/tag/test'
    take_screenshot
  end

  test 'stats mobile' do
    visit '/stats'
    take_screenshot
  end

  test 'blog mobile' do
    visit '/blog'
    take_screenshot
  end

  test 'people mobile' do
    visit '/people'
    take_screenshot
  end

  test 'wiki page with inline grids mobile' do
    node = nodes(:place) # /wiki/chicago page
    node.add_tag('place', users(:bob)) # lets get a map on this page! 
    node.add_tag('lon:-71.4', users(:bob))
    node.add_tag('lat:41.7', users(:bob))
    revision = node.latest
    revision.body = "Inline grids:\n\n## Thumbnails\n\n[notes:grid:test]\n\n## Nodes\n\n[nodes:test]\n\n## Notes\n\n[notes:test]\n\n## Wikis\n\n[wikis:test]\n\n## Questions\n\n[questions:test]\n\n## Activities\n\n[activities:test]\n\n## Thumbnails\n\n[notes:grid:test]\n\nThis should not render:\n\n`[nodes:tagname]`"
    revision.save
    visit node.path
    take_screenshot
  end

end
