require 'test_helper'

class TagControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
    @node =  FactoryGirl.create(:drupal_node,uid: @user.id)
  end

  # create accepts comma-delimited list of tags
  def test_add_tag
    UserSession.new(@user)
    post :create, :name => 'mytag', :nid => @node.id, :uid => @user.id
    assert_redirected_to(@node.path)
  end

  # create returns JSON list of errors in response[:errors]
  def test_add_duplicate_tag
    UserSession.new(@user)
    post :create, :name => 'mytag', :nid => @node.id, :uid => @user.id
    assert_redirected_to(@node.path)

    # 2nd identical tag:
    post :create, :name => 'mytag', :nid => @node.id, :uid => @user.id
    assert_redirected_to(@node.path)
    assert_equal "Error: that tag already exists.", assigns['output']['errors'][0]
  end

  def test_add_tag_not_logged_in
    @user.destroy
    post :create, :name => 'mytag', :nid => @node.id, :uid => 1
    assert_redirected_to('/login?return_to='+URI.encode(request.env['PATH_INFO']))
  end

end
