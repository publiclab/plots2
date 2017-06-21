require 'test_helper'

class NodeSharedTest < ActiveSupport::TestCase
  test 'that NodeShared can be used to convert short codes like [notes:foo] into tables which list notes' do
    before = "Here are some notes in a table: \n\n[notes:test] \n\nThis is how you make it work:\n\n`[notes:tagname]`\n\n `[notes:tagname]`\n\nMake sense?"
    html = NodeShared.notes_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid notes-grid notes-grid-test notes-grid-test-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 6, html.scan('notes-grid-test').length
  end

  test 'that NodeShared can be used to convert short codes like [questions:foo] into tables which list questions' do
    before = "Here are some questions in a table: \n\n[questions:test] \n\nThis is how you make it work:\n\n`[questions:tagname]`\n\n `[questions:tagname]`\n\nMake sense?"
    html = NodeShared.questions_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid questions-grid questions-grid-test questions-grid-test-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('questions-grid-test').length
  end

  test 'that NodeShared can be used to convert short codes like [activities:foo] into tables which list activity notes' do
    before = "Here are some activities in a table: \n\n[activities:spectrometer] \n\nThis is how you make it work:\n\n`[activities:tagname]`\n\nMake sense?"
    html = NodeShared.activities_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid activity-grid activity-grid-spectrometer activity-grid-spectrometer-').length
    assert_equal 7, html.scan('<td').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('activity-grid-spectrometer').length
  end

  test 'that NodeShared can be used to convert short codes like [upgrades:foo] into tables which list upgrade notes' do
    before = "Here are some upgrades in a table: \n\n[upgrades:test] \n\nThis is how you make it work:\n\n`[upgrades:tagname]`\n\nMake sense?"
    html = NodeShared.upgrades_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid upgrades-grid upgrades-grid-test upgrades-grid-test-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('upgrades-grid-test').length
  end

  test 'that NodeShared can be used to convert short codes like [notes:foo] into tables which list notes, even after text has been markdown-ified' do
    before = "This shouldn't actually produce a table:\n\n`[notes:tagname]`\n\nOr this:\n\n `[notes:tagname]`"
    html = NodeShared.notes_grid(before)
    assert_equal 0, html.scan('<table class="table inline-grid notes-grid notes-grid-test notes-grid-test-').length
    assert_equal 0, html.scan('<table').length
    assert_equal 0, html.scan('notes-grid-test').length
  end

  test 'that NodeShared can be used to convert short codes like [notes:foo] into tables which list notes, even in code tags' do
    before = "This shouldn't actually produce a table:\n\n<code>[notes:tagname]</code>"
    html = NodeShared.notes_grid(before)
    assert_equal 0, html.scan('<table class="table inline-grid notes-grid notes-grid-test notes-grid-test-').length
    assert_equal 0, html.scan('<table').length
    assert_equal 0, html.scan('notes-grid-test').length
  end

  test 'that NodeShared can be used to convert short codes like [map:content:lat:lon] into maps which display notes' do
    before = "Here are some notes in a map: \n\n[map:content:71.00:52.00] \n\nThis is how you make it work:\n\n`[map:content:71.00:52.00]`\n\n `[map:content:71.00:52.00]`\n\nMake sense?"
    html = NodeShared.notes_map(before)
    assert_equal 1, html.scan('<div class="leaflet-map"').length
    assert_equal 1, html.scan('L.marker').length
  end

  test 'that NodeShared can be used to convert short codes like [map:tag:blog:lat:lon] into maps which display notes, but only those tagged with "blog"' do
    before = "Here are some notes in a map: \n\n[map:tag:blog:71.00:52.00] \n\nThis is how you make it work:\n\n`[map:tag:blog:71.00:52.00]`\n\n `[map:tag:blog:71.00:52.00]`\n\nMake sense?"
    html = NodeShared.notes_map_by_tag(before)
    assert_equal 1, html.scan('<div class="leaflet-map"').length
    assert_equal 1, html.scan('L.marker').length
  end
end
