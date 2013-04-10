require 'test_helper'

class PublicPagesTest < ActionDispatch::IntegrationTest
  # we need some fixtures yo!

  test "browse front page" do
    drupal_user = FactoryGirl.create(:drupal_users, :name => "billy", :mail => "billy@pxlshp.com") # currently dependent on drupal users, though we should drop that
    user =  FactoryGirl.create(:user, :username => drupal_user.name, :email => drupal_user.mail)

    node =  FactoryGirl.create(:drupal_node, :uid => user.uid)
    node_revision = FactoryGirl.create(:drupal_node_revision)
    node.drupal_node_counter.totalcount = 30
    node.drupal_node_counter.save
    get "/"
    assert_response :success
  end

  # dependent on above
  test "view notes for an author" do
    drupal_user = FactoryGirl.create(:drupal_users, :name => "jane", :mail => "jane@pxlshp.com") # currently dependent on drupal users, though we should drop that
    user =  FactoryGirl.create(:user, :username => drupal_user.name, :email => drupal_user.mail)

    node =  FactoryGirl.create(:drupal_node, :uid => user.uid)
    node_revision = FactoryGirl.create(:drupal_node_revision)
    node.drupal_node_counter.totalcount = 30
    node.drupal_node_counter.save
    get "/notes/author/"+user.username
    assert_response :success
  end

  test "browse /research" do
    get "/research"
    assert_response :success
  end

  test "browse /login" do
    get "/login"
    assert_response :success
  end

  test "browse /profile/*" do
    drupal_user = FactoryGirl.create(:drupal_users, :name => "bobby", :mail => "bobby@pxlshp.com") # currently dependent on drupal users, though we should drop that
    user =  FactoryGirl.create(:user, :username => drupal_user.name, :email => drupal_user.mail)
    get "/profile/"+user.username
    assert_response :success
  end

  # add: /tag/something, /search/something, /wiki/something, /login

  test "browse /about" do
    drupal_user = FactoryGirl.create(:drupal_users, :name => "carla", :mail => "carla@pxlshp.com") # currently dependent on drupal users, though we should drop that
    user =  FactoryGirl.create(:user, :username => drupal_user.name, :email => drupal_user.mail)
    node =  FactoryGirl.create(:drupal_node, :uid => user.uid, :title => "About", :type => "page")
    node_revision = FactoryGirl.create(:drupal_node_revision, :body => "About Public Lab", :nid => node.id)
    get "/wiki/about"
    assert_response :success
  end

end

