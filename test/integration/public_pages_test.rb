require 'test_helper'

class PublicPagesTest < ActionDispatch::IntegrationTest

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
    @drupal_user =  FactoryGirl.create(:drupal_users, :name => @user.username, :mail => @user.email)
  end

  def teardown
    @user.destroy
    @drupal_user.destroy
  end

  test "browse front page" do
    node =  FactoryGirl.create(:drupal_node, :uid => @user.uid)
    node_revision = FactoryGirl.create(:drupal_node_revision, :nid => node.id)
    node.drupal_node_counter.totalcount = 30
    node.drupal_node_counter.save
    get "/"
    assert_response :success
    node.destroy
  end

  test "view notes for an author" do
    node =  FactoryGirl.create(:drupal_node, :uid => @user.uid)
    node_revision = FactoryGirl.create(:drupal_node_revision, :nid => node.id)
    node.drupal_node_counter.totalcount = 30
    node.drupal_node_counter.save
    get "/notes/author/"+@user.username
    assert_response :success
    node.destroy
  end

  test "browse /research" do
    node =  FactoryGirl.create(:drupal_node, :uid => @user.uid)
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

  test "browse /about" do
    node =  FactoryGirl.create(:drupal_node, :uid => @user.uid, :title => "About", :type => "page")
    node_revision = FactoryGirl.create(:drupal_node_revision, :body => "About Public Lab", :nid => node.id)
    get "/wiki/about"
    assert_response :success
    node.destroy
  end

  # add: /tag/something, /search/something

end

