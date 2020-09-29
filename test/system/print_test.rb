require "application_system_test_case"

class PrintTest < ApplicationSystemTestCase

  test "open print in new tab for note" do
    visit nodes(:one).path
    find('#menu-btn').click()
    find("#print-new").click()
    assert page.driver.browser.window_handles.size == 2
  end

  test "open print in new tab for wiki" do
    visit nodes(:wiki_page).path
    find('#menu-btn').click()
    find("#print-new").click()
    assert page.driver.browser.window_handles.size == 2
  end

  test "check different elements in print for note" do
    visit "/notes/print/#{nodes(:sunny_day_note).nid}"
    take_screenshot
    assert_selector('#content-window blockquote p', text: "But my knees were far too weak To stand in your arms Without falling to your feet")
    assert_selector('#content-window table', text: "col0 col1 col2 col3\ncell cell cell cell\ncell cell cell cell\ncell cell cell cell\ncell cell cell cell")
    assert_selector('#content-window code', text: "code goes here")
    assert_selector('#content-window iframe', visible: true)
  end

end
