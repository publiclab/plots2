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

  test "browse /research" do
    get "/research"
    assert_response :success
  end

  #test "browse /about" do
  #  get "/about"
  #  assert_response :success
  #end

end
