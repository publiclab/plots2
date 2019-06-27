require "application_system_test_case"

class ScreenshotsTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'front' do
    visit '/'
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

  test 'tag page' do
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

  test 'questions' do
    visit '/questions'
    take_screenshot
  end
  
  test 'questions_shadow' do
    visit '/questions_shadow'
    take_screenshot
  end

  test 'wiki page with inline grids' do
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
  
  test 'blog page with location modal' do
    visit '/people'
    find('a.blurred-location-input').click
    # click_on(class: 'blurred-location-input') # alternative
    fill_in("placenameInput", with: "Pusan")
    take_screenshot
  end

end
