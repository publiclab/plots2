# def index
# def show
# def widget
# def blog
# def author
# def barnstar
# def create
# def delete
# def suggested
# def rss
# def contributors
# def contributors_index

require 'test_helper'

class TagControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
  end

  # create accepts comma-delimited list of tags
  def test_add_tag
    UserSession.new(@user)
    post :create, :name => 'mytag', :nid => node(:one).nid, :uid => @user.id
    assert_redirected_to(node(:one).path)
  end

  def test_add_invalid_tag
    UserSession.new(@user)
    post :create, :name => 'my invalid tag $_', :nid => node(:one).nid, :uid => @user.id
    assert_redirected_to(node(:one).path)
    assert_equal "Error: tags can only include letters, numbers, and dashes", assigns['output']['errors'][0]
  end

  # create returns JSON list of errors in response[:errors]
  def test_add_duplicate_tag
    UserSession.new(@user)
    post :create, :name => 'mytag', :nid => node(:one).nid, :uid => @user.id
    assert_redirected_to(node(:one).path)

    # 2nd identical tag:
    post :create, :name => 'mytag', :nid => node(:one).nid, :uid => @user.id
    assert_redirected_to(node(:one).path)
    assert_equal "Error: that tag already exists.", assigns['output']['errors'][0]
  end

  def test_add_tag_not_logged_in
    @user.destroy
    post :create, :name => 'mytag', :nid => node(:one).nid, :uid => 1
    assert_redirected_to('/login?return_to='+URI.encode(request.env['PATH_INFO']))
  end

end
