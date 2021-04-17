require 'test_helper'

class NodeTagTest < ActiveSupport::TestCase
  test 'tag basics' do
    node = nodes(:one)
    assert node.has_tag('activity:spectrometer')
    assert node.has_tag('activi*')
    assert node.normal_tags.length < node.tags.length
    assert_equal node.tagnames, node.tags.collect(&:name)
    assert Tag.find_nodes_by_type('spectrometer').to_a.include?(node)
    assert Tag.find_nodes_by_type_with_all_tags(['spectrometer']).to_a.include?(node)
    assert_not_nil Tag.follower_count('spectrometer')
    assert_not_nil Tag.followers('spectrometer')
    assert_not_nil tags(:spectrometer).weekly_tallies
    assert_not_nil Tag.subscribers([tags(:spectrometer)])
  end

  # as we eliminate legacy Drupal naming schemes, these can be removed:
  test 'tag method aliases' do
    node = nodes(:one)
    assert_equal node.tags, node.tag
    assert_equal node.node_tags, node.node_tag
  end

  test 'power tag basics' do
    assert Tag.is_powertag?('activity:spectrometer')
    node = nodes(:one)
    assert node.has_power_tag('activity')
    assert_equal 'spectrometer', node.power_tag('activity')
    assert_equal 'spectrometer', node.power_tag('activity')
    assert_equal ['spectrometer'], node.power_tags('activity')
    assert_equal 'String', node.power_tags('activity').first.class.to_s
    assert_equal 'NodeTag', node.power_tag_objects('activity').first.class.to_s
  end

  test 'power tag based node features' do
    node = nodes(:one)
    assert node.response_count
    assert node.responses
    assert node.responded_to
    assert_equal false, node.has_mailing_list?
    assert_equal false, node.lat
    assert_equal false, node.lon
  end

  test "can't powertag with: yourself" do
    user = nodes(:blog).author
    tagname = "with:#{user.username}"
    assert_equal I18n.t('node.cannot_add_yourself_coauthor'), nodes(:blog).can_tag(tagname, user, true)
    assert_not nodes(:blog).can_tag(tagname, user)
  end

  test 'can powertag with: another user' do
    jeff = nodes(:blog).author
    bob = users(:bob)
    assert bob.username != jeff.username
    assert nodes(:blog).can_tag("with:#{bob.username}", jeff)
  end

  test "can't tag with: a nonexistent user" do
    user = users(:bob)
    tagname = 'with:steven'
    assert_equal I18n.t('node.cannot_find_username'), nodes(:blog).can_tag(tagname, user, true)
    assert_not nodes(:blog).can_tag(tagname, user)
  end

  test "can't powertag with: if you're not author" do
    bob = users(:bob)
    jeff = users(:jeff)
    node = Node.new(uid: jeff.id,
                    type: 'note',
                    title: 'My research note')
    tagname = "with:#{jeff.username}"
    assert_equal I18n.t('node.only_author_use_powertag'), node.can_tag(tagname, bob, true)
    assert_not node.can_tag(tagname, bob)
  end

  test 'can rsvp yourself' do
    user = nodes(:blog).author
    tagname = "rsvp:#{user.username}"
    assert nodes(:blog).can_tag(tagname, user)
    assert nodes(:blog).can_tag(tagname, user)
  end

  test "can't rsvp someone else" do
    user = users(:bob)
    jeff = users(:jeff)
    node = Node.new(uid: user.id,
                    type: 'note',
                    title: 'My research note')
    tagname = "rsvp:#{jeff.username}"
    assert_not_equal true,  node.can_tag(tagname, user, true) # return errors with optional 3rd parameter
    assert_not_equal false, node.can_tag(tagname, user, true)
    assert_equal I18n.t('node.only_RSVP_for_yourself'), node.can_tag(tagname, user, true)
    assert_not node.can_tag(tagname, user) # default is true/false
  end

  test 'only admins can lock pages' do
    assert_not nodes(:blog).can_tag('locked', users(:bob))
    assert nodes(:blog).can_tag('locked', users(:admin))
    assert_equal I18n.t('node.only_admins_can_lock'), nodes(:blog).can_tag('locked', users(:bob), true)
  end

  test 'redirect tags to non-existent pages should not be accepted' do
    user = users(:bob)
    tagname = 'redirect:nonsense'
    assert_not nodes(:blog).can_tag(tagname, user)
    assert_equal I18n.t('node.page_does_not_exist'), nodes(:blog).can_tag(tagname, user, true)
  end
end
