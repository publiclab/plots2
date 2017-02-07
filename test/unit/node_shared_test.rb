require 'test_helper'

class NodeSharedTest < ActiveSupport::TestCase

  test "that NodeShared can be used to convert short codes like [notes:foo] into tables which list notes" do
    before = "Here are some notes in a table: \n\n[notes:test] \n\nThis is how you make it work:\n\n`[notes:tagname]`\n\n `[notes:tagname]`\n\nMake sense?"
    assert NodeShared.notes_grid(before)
    assert_equal 1, NodeShared.notes_grid(before).scan('<table class="table inline-grid notes-grid notes-grid-test notes-grid-test-').length
    assert_equal 1, NodeShared.notes_grid(before).scan('<table').length
    assert_equal 3, NodeShared.notes_grid(before).scan('notes-grid-test').length
  end

  test "that NodeShared can be used to convert short codes like [activities:foo] into tables which list activity notes" do
    before = "Here are some activities in a table: \n\n[activities:spectrometer] \n\nThis is how you make it work:\n\n`[activities:tagname]`\n\nMake sense?"
    assert NodeShared.activities_grid(before)
    assert_equal 1, NodeShared.activities_grid(before).scan('<table class="table inline-grid activity-grid activity-grid-spectrometer activity-grid-spectrometer-').length
    assert_equal 7, NodeShared.activities_grid(before).scan('<td').length
    assert_equal 1, NodeShared.activities_grid(before).scan('<table').length
    assert_equal 3, NodeShared.activities_grid(before).scan('activity-grid-spectrometer').length
  end

  test "that NodeShared can be used to convert short codes like [upgrades:foo] into tables which list upgrade notes" do
    before = "Here are some upgrades in a table: \n\n[upgrades:test] \n\nThis is how you make it work:\n\n`[upgrades:tagname]`\n\nMake sense?"
    assert NodeShared.upgrades_grid(before)
    assert_equal 1, NodeShared.upgrades_grid(before).scan('<table class="table inline-grid upgrades-grid upgrades-grid-test upgrades-grid-test-').length
    assert_equal 1, NodeShared.upgrades_grid(before).scan('<table').length
    assert_equal 3, NodeShared.upgrades_grid(before).scan('upgrades-grid-test').length
  end

  test "that NodeShared can be used to convert short codes like [notes:foo] into tables which list notes, even after text has been markdown-ified" do
    before = "This shouldn't actually produce a table:\n\n`[notes:tagname]`\n\nOr this:\n\n `[notes:tagname]`"
    html = RDiscount.new(before).to_html
    assert_equal 0, NodeShared.notes_grid(before).scan('<table class="table inline-grid notes-grid notes-grid-test notes-grid-test-').length
    assert_equal 0, NodeShared.notes_grid(before).scan('<table').length
    assert_equal 0, NodeShared.notes_grid(before).scan('notes-grid-test').length
  end

  test "that NodeShared can be used to convert short codes like [notes:foo] into tables which list notes, even in code tags" do
    before = "This shouldn't actually produce a table:\n\n<code>[notes:tagname]</code>"
    html = RDiscount.new(before).to_html
    assert_equal 0, NodeShared.notes_grid(before).scan('<table class="table inline-grid notes-grid notes-grid-test notes-grid-test-').length
    assert_equal 0, NodeShared.notes_grid(before).scan('<table').length
    assert_equal 0, NodeShared.notes_grid(before).scan('notes-grid-test').length
  end

end
