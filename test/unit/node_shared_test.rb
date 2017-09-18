require 'test_helper'

class NodeSharedTest < ActiveSupport::TestCase
  test 'that NodeShared can be used to convert short codes like [notes:foo] into tables which list notes' do
    before = "Here are some notes in a table: \n\n[notes:test] \n\nThis is how you make it work:\n\n`[notes:tagname]`\n\n `[notes:tagname]`\n\nMake sense?"
    html = NodeShared.notes_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid notes-grid notes-grid-test notes-grid-test-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('notes-grid-test').length
    assert html.scan('<td class="title">').length > 1
  end

  test 'that NodeShared can be used to convert doubled short codes like [notes:activity:spectrometer] into tables which list notes with the tag `activity:spectrometer`' do
    before = "Here are some notes in a table: \n\n[notes:activity:spectrometer] \n\nThis is how you make it work:\n\n`[notes:activity:spectrometer]`\n\nMake sense?"
    html = NodeShared.notes_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid notes-grid notes-grid-activity-spectrometer notes-grid-activity-spectrometer-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('notes-grid-activity-spectrometer').length
    assert html.scan('<td class="title">').length > 1
  end

  test 'that NodeShared can be used to convert short codes like [questions:foo] into tables which list questions' do
    before = "Here are some questions in a table: \n\n[questions:spectrometer] \n\nThis is how you make it work:\n\n`[questions:tagname]`\n\n `[questions:tagname]`\n\nMake sense?"
    html = NodeShared.questions_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid questions-grid questions-grid-spectrometer questions-grid-spectrometer-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('questions-grid-spectrometer').length
    assert html.scan('<td class="title">').length > 1
  end

  test 'that NodeShared can be used to convert short codes like [activities:foo] into tables which list activity notes' do
    before = "Here are some activities in a table: \n\n[activities:spectrometer] \n\nThis is how you make it work:\n\n`[activities:tagname]`\n\nMake sense?"
    html = NodeShared.activities_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid activity-grid activity-grid-spectrometer activity-grid-spectrometer-').length
    assert_equal 7, html.scan('<td').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('activity-grid-spectrometer').length
    assert html.scan('<td class="title">').length > 1
  end

  test 'that NodeShared can be used to convert short codes like [upgrades:latest] into tables which list upgrade notes' do
    before = "Here are some upgrades in a table: \n\n[upgrades:latest] \n\nThis is how you make it work:\n\n`[upgrades:tagname]`\n\nMake sense?"
    html = NodeShared.upgrades_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid upgrades-grid upgrades-grid-latest upgrades-grid-latest-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('upgrades-grid-latest').length
    assert html.scan('<td class="title">').length > 1
  end

  test 'that NodeShared does not convert short codes like [notes:foo] into tables which list notes, when inside `` marks' do
    before = "This shouldn't actually produce a table:\n\n`[notes:tagname]`\n\nOr this:\n\n `[notes:tagname]`"
    html = NodeShared.notes_grid(before)
    assert_equal 0, html.scan('<table class="table inline-grid notes-grid notes-grid').length
    assert_equal 0, html.scan('<table').length
    assert_equal 0, html.scan('notes-grid').length
  end

  test 'that NodeShared does not convert short codes like [notes:foo] into tables which list notes, when in code tags' do
    before = "This shouldn't actually produce a table:\n\n<code>[notes:tagname]</code>"
    html = NodeShared.notes_grid(before)
    assert_equal 0, html.scan('<table class="table inline-grid notes-grid notes-grid').length
    assert_equal 0, html.scan('<table').length
    assert_equal 0, html.scan('notes-grid').length
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

  test 'that NodeShared can be used to convert short codes like [people:organizer] into maps which display notes, but only those tagged with "organizer"' do
    before = "Here are some people in a grid: \n\n[people:organizer] \n\nThis is how you make it work:\n\n`[people:organizer]`\n\nMake sense?"
    html = NodeShared.people_grid(before)
    assert_equal 1, html.scan('<table class="table inline-grid people-grid people-grid-organizer people-grid-organizer-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 6, html.scan('people-grid').length
  end
end
