require 'test_helper'

class PublicPagesTest < ActionDispatch::IntegrationTest

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
    @user.save({})
  end

  def teardown
    @user.destroy
  end

  test "browse front page" do
    title = "Test node for front page test"
    # was failing title uniquness and unique primary key due to nonfunctioning factory_girl sequencer
    node =  FactoryGirl.create(:drupal_node, :uid => @user.uid, :title => title, :nid => 10)
    node_revision = FactoryGirl.create(:drupal_node_revision, :nid => node.id, :title => title)
    node.drupal_node_counter.totalcount = 30
    node.drupal_node_counter.save
    get "/"
    assert_response :success
    node.destroy
  end

  # need to create constructor for maps, with bbox data... GeoRuby research
 # test "browse /maps" do
 #   title = "Test map"
 #   # was failing title uniquness and unique primary key due to nonfunctioning factory_girl sequencer
 #   node =  FactoryGirl.create(:drupal_node, :uid => @user.uid, :title => title, :nid => 10, :type => 'map')
 #   node_revision = FactoryGirl.create(:drupal_node_revision, :nid => node.id, :title => title)
 #   get "/maps"
 #   assert_response :success
 #   node.destroy
 # end

  test "view notes for an author" do
    title = "New title for author notes test"
    # was failing title uniquness and unique primary key due to nonfunctioning factory_girl sequencer
    node =  FactoryGirl.create(:drupal_node, :uid => @user.uid, :title => title, :nid => 11)
    node_revision = FactoryGirl.create(:drupal_node_revision, :nid => node.id, :title => title)
    node.drupal_node_counter.totalcount = 30
    node.drupal_node_counter.save
    get "/notes/author/"+@user.username
    assert_response :success
    node.destroy
  end

  # must destroy all old nodes
  test "browse /research" do
    DrupalNode.find(:all).each do |n|
      n.destroy
    end
    title = "New title for research test"
    # was failing title uniquness and unique primary key due to nonfunctioning factory_girl sequencer
    node =  FactoryGirl.create(:drupal_node, :uid => @user.uid, :title => title, :nid => 12) 
    node_revision = FactoryGirl.create(:drupal_node_revision, :nid => node.id)
    get "/research"
    assert_response :success
    node.destroy
  end

  test "browse /login" do
    get "/login"
    assert_response :success
  end

  test "browse /profile/*" do
    get "/profile/"+@user.username
    assert_response :success
  end

  test "browse /wiki/foo" do
    node =  FactoryGirl.create(:drupal_node, :uid => @user.uid, :title => "Foo", :type => "page", :nid => 13) 
    # was failing title uniquness and unique primary key due to nonfunctioning factory_girl sequencer
    node_revision = FactoryGirl.create(:drupal_node_revision, :body => "Foo Public Lab", :nid => node.id, :uid => @user.uid)
    get "/wiki/foo"
    assert_response :success
    node.destroy
  end

  # add: /tag/something, /search/something

end

