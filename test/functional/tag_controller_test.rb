# def barnstar
# def create
# def delete
# def suggested
# def contributors_index

require 'test_helper'

class TagControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  # create accepts comma-delimited list of tags
  test "add tag" do
    UserSession.create(rusers(:bob))
    post :create, :name => 'mytag', :nid => node(:one).nid, :uid => rusers(:bob).id
    assert_redirected_to(node(:one).path)
  end

  test "validate unused tag" do
    UserSession.create(rusers(:bob))
    get :contributors, :id => 'question:*'
    assert_template :contributors
    assert_tag :tag => 'p', :child => /No contributors for that tag/
  end

  test "add invalid tag" do
    UserSession.create(rusers(:bob))
    post :create, :name => 'my invalid tag $_', :nid => node(:one).nid, :uid => rusers(:bob).id
    assert_redirected_to(node(:one).path)
    assert_equal "Error: tags can only include letters, numbers, and dashes", assigns['output']['errors'][0]
  end

  # create returns JSON list of errors in response[:errors]
  test "add duplicate tag" do
    UserSession.create(rusers(:bob))
    post :create, :name => 'mytag', :nid => node(:one).nid, :uid => rusers(:bob)
    assert_redirected_to(node(:one).path)

    # 2nd identical tag:
    post :create, :name => 'mytag', :nid => node(:one).nid, :uid => rusers(:bob)
    assert_redirected_to(node(:one).path)
    assert_equal "Error: that tag already exists.", assigns['output']['errors'][0]
  end

  test "add tag not logged in" do
    post :create, :name => 'mytag', :nid => node(:one).nid, :uid => 1
    assert_redirected_to('/login')
  end

  test "tag index" do
    get :index
    assert :success
    assert_equal assigns['tags'].sort_by { |rev| rev.count }, assigns['tags']
    assert_equal assigns['tags'].collect(&:name), assigns['tags'].collect(&:name).uniq
    assert_false assigns['tags'].collect(&:drupal_node).flatten.collect(&:status).include?(0)
    assert_not_nil :tags
  end

  test "tag show" do
    get :show, id: DrupalTag.last.name
    assert :success
    assert_not_nil :tags
  end

  test "tag widget" do
    get :widget, id: DrupalTag.last.name
    assert :success
    assert_not_nil :notes
  end

  test "tag blog" do
    get :blog, id: DrupalTag.last.name
    assert :success
    assert_not_nil :notes
    assert_not_nil :tags
  end

  test "tag author" do
    get :author, id: User.last.username
    assert :success
  end

  test "tag rss" do
    get :rss, tagname: DrupalTag.last.name
    assert :success
    assert_not_nil :notes
  end

  test "tag contributors" do
    get :contributors, id: DrupalTag.last.name
    assert :success
    assert_not_nil :notes
    assert_not_nil :users
    assert_not_nil :tag
  end

  test "adds comment when awarding a barnstar" do
    ApplicationController.any_instance.stubs(:current_user).returns(User.first)
    assert_difference 'DrupalComment.count' do
      post :barnstar, :nid => DrupalNode.last.nid, :star => "basic"
      assert_equal "#{User.first.username} awards a <a href=\"publiclab.org/wiki/barnstars\">barnstar</a> to #{DrupalNode.last.drupal_users.name} for their awesome contribution!", DrupalComment.last.body
    end
  end
end
