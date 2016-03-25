require 'test_helper'

class DrupalNodeTest < ActiveSupport::TestCase

  test "create a node" do
    # in testing, uid and id should be matched, although this is not yet true in production db
    node =  DrupalNode.new({:uid => rusers(:bob).id})
    node.title = "My new node"
    assert node.save!
  end

  test "create a research note" do
    node =  DrupalNode.new({
      uid: rusers(:bob).id,
      type: 'note',
      title: 'My research note'
    })
    assert node.save!
  end

  test "create a wiki page" do
    node =  DrupalNode.new({
      uid: rusers(:bob).id,
      type: 'page',
      title: 'My wiki page'
    })
    assert node.save!
  end

  test "create a node_revision" do
    # in testing, uid and id should be matched, although this is not yet true in production db
    node_revision =  DrupalNodeRevision.new({
      :uid => rusers(:bob).id,
      :nid => node(:one).nid
    })
    node_revision.title = "My new node"
    node_revision.body = "My new node"
    assert node_revision.save!
  end

  #test "should not save node without title, or anything else" do
    #node = DrupalNode.new
    #assert !node.save
  #end

end
