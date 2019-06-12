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

  test 'tags' do
    visit '/tags'
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

  test 'wiki page with inline grids' do
    node = nodes(:place) # /wiki/chicago page
    revision = node.latest
    revision.body = "Inline grids:\n\n## Thumbnails\n\n[notes:grid:test]\n\n## Nodes\n\n[nodes:test]\n\n## Notes\n\n[notes:test]\n\n## Wikis\n\n[wikis:test]\n\n## Questions\n\n[questions:test]\n\n## Activities\n\n[activities:test]\n\n## Thumbnails\n\n[notes:grid:test]\n\nThis should not render:\n\n`[nodes:tagname]`"
    revision.save
    visit node.path
    take_screenshot
  end

end
