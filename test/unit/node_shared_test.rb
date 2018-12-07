require 'test_helper'

class NodeSharedTest < ActiveSupport::TestCase
  test 'that NodeShared can be used to convert short codes like [nodes:foo] into tables which list nodes and wikis(pages)' do
    before = "Here are some nodes in a table: \n\n[nodes:test] \n\nThis is how you make it work:\n\n`[nodes:tagname]`\n\n `[nodes:tagname]`\n\nMake sense?"
    html = NodeShared.nodes_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid nodes-grid nodes-grid-test nodes-grid-test-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('nodes-grid-test').length
    assert html.scan('<td class="author">').length > 1
  end

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
    assert_equal 1, Node.where(status: 1, type: 'note')
                        .includes(:revision, :tag)
                        .references(:term_data)
                        .where('term_data.name = ?', 'activity:spectrometer')
                        .count
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid notes-grid notes-grid-activity-spectrometer notes-grid-activity-spectrometer-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('notes-grid-activity-spectrometer').length
    assert_equal 1, html.scan('<td class="title">').length
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
    assert_equal 1, Node.activities('spectrometer').length
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid activity-grid activity-grid-spectrometer activity-grid-spectrometer-').length
    assert_equal 7, html.scan('<td').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('activity-grid-spectrometer').length
    assert_equal 1, html.scan('<td class="title">').length
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

  test 'that NodeShared works if code starts at the beginning of the line' do
    before = "[wikis:foo]"
    html = NodeShared.wikis_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid wikis-grid wikis-grid-foo wikis-grid-foo-').length
    assert_equal 1, html.scan('<table').length
  end

  test 'that NodeShared does not replace characters before codes like [wikis:foo]' do
    before = "Here is a code a[wikis:foo]"
    html = NodeShared.wikis_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid wikis-grid wikis-grid-foo wikis-grid-foo-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 1, html.scan('Here is a code a').length
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

  test 'that NodeShared can be used to convert short codes like [map:people:___:___] into maps which display peoples locations' do
    before = "Here are some people in a map: \n\n[map:people:41.00:-90.01] \n\nThis is how you make it work:\n\n`[map:people:41:-90]`\n\nMake sense?"
    html = NodeShared.people_map(before)
    assert_equal 1, html.scan('<div class="leaflet-map"').length
  end

  test 'that NodeShared can be used to convert short codes like [people:organizer] into maps which display notes, but only those tagged with "organizer"' do
    before = "Here are some people in a grid: \n\n[people:organizer] \n\nThis is how you make it work:\n\n`[people:organizer]`\n\nMake sense?"
    html = NodeShared.people_grid(before)
    assert_equal 1, html.scan('<table class="table inline-grid people-grid people-grid-organizer people-grid-organizer-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 6, html.scan('people-grid').length
  end

  test 'that NodeShared can be used to convert short codes like [graph://example.com] into graphs which display csv data' do
    before = "Here's an inline csv: \n\n[graph://localhost:3000/test.csv] \n\nThis is how you make it work:\n\n`[graph://localhost:3000/test.csv]`\n\nMake sense?"
    html = NodeShared.graph_grid(before)
    assert_equal 1, html.scan('<canvas class="inline-graph"').length
  end

  test 'that NodeShared can be used to convert short codes like [wikis:_tagname_] into tables which list wikis tagged with given tagname' do
    before = "Here are some wikis in a table: \n\n[wikis:test] \n\nThis is how you make it work:\n\n`[wikis:tagname]`\n\n `[wiksi:tagname]`\n\nMake sense?"
    html = NodeShared.wikis_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid wikis-grid wikis-grid-test wikis-grid-test-').length
    assert_equal 1, html.scan('<table').length
  end

  test 'about ability of power tags to exclude tags like [notes:test!awesome]' do
    before = "Here are some notes in a table: \n\n[notes:test!awesome]"
    html = NodeShared.notes_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid notes-grid notes-grid-test notes-grid-test-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('notes-grid-test').length
    assert_equal 4, html.scan('<td').length
  end

  test 'about ability of power tags to exclude tags like [questions:foo!foo1]' do
    before = "Here are some questions in a table: \n\n[questions:spectrometer!awesome] \n\nThis is how you make it work:\n\n`[questions:tagname!tagname]`\n\n `[questions:tagname!tagname]`\n\nMake sense?"
    html = NodeShared.questions_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid questions-grid questions-grid-spectrometer questions-grid-spectrometer-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('questions-grid-spectrometer').length
    assert html.scan('<td class="title">').length > 1
  end

  test 'about ability of power tags to exclude tags like [questions:foo!answered]' do
    before = "Here are some questions in a table: \n\n[questions:spectrometer!answered] \n\nThis is how you make it work:\n\n`[questions:tagname!answered]`\n\n `[questions:tagname!answered]`\n\nMake sense?"
    html = NodeShared.questions_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid questions-grid questions-grid-spectrometer questions-grid-spectrometer-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('questions-grid-spectrometer').length
    assert html.scan('<td class="title">').length > 1
  end

  test 'about ability of power tags to exclude tags like [activities:foo!foo1]' do
    before = "Here are some activities in a table: \n\n[activities:spectrometer!test] \n\nThis is how you make it work:\n\n`[activities:tagname!tagname]`\n\nMake sense?"
    html = NodeShared.activities_grid(before)
    assert_equal 1, Node.activities('spectrometer').length
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid activity-grid activity-grid-spectrometer activity-grid-spectrometer-').length
    assert_equal 4, html.scan('<td').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('activity-grid-spectrometer').length
  end

  test 'about ability of power tags to exclude tags like [upgrades:foo!foo1]' do
    before = "Here are some upgrades in a table: \n\n[upgrades:latest!test] \n\nThis is how you make it work:\n\n`[upgrades:tagname!exclude]`\n\nMake sense?"
    html = NodeShared.upgrades_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid upgrades-grid upgrades-grid-latest upgrades-grid-latest-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 5, html.scan('upgrades-grid-latest').length
    assert html.scan('<td class="title">').length > 1
  end

  test 'about ability of power tags to exclude tags like [wikis:foo!foo1]' do
    before = "Here are some wikis in a table: \n\n[wikis:test!awesome] \n\nThis is how you make it work:\n\n`[wikis:tagname!tag]`\n\n `[wiksi:tagname!tag]`\n\nMake sense?"
    html = NodeShared.wikis_grid(before)
    assert html
    assert_equal 1, html.scan('<table class="table inline-grid wikis-grid wikis-grid-test wikis-grid-test-').length
    assert_equal 1, html.scan('<table').length
  end

  test 'about ability of power tags to exclude tags like [people:organizer!foo1]' do
    before = "Here are some people in a grid: \n\n[people:organizer!skill:rails] \n\nThis is how you make it work:\n\n`[people:organizer!skill:rails]`\n\nMake sense?"
    html = NodeShared.people_grid(before)
    assert_equal 1, html.scan('<table class="table inline-grid people-grid people-grid-organizer people-grid-organizer-').length
    assert_equal 1, html.scan('<table').length
    assert_equal 6, html.scan('people-grid').length
  end
end
