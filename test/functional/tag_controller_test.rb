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

  test "should take node type as question if tag is a question tag" do
    tag = tags(:question)
    get :show, id: tag.name
    assert_equal "questions", assigns(:node_type)
  end

  test "should take node type as note if tag is not a question tag" do
    tag = tags(:awesome)
    get :show, id: tag.name
    assert_equal "note", assigns(:node_type)
  end

  test "should list only question in question view" do
    tag = tags(:question)
    get :show, id: tag.name
    questions = assigns(:questions)
    expected = [node(:question), node(:question2)]
    assert_not_nil assigns(:questions)
    assert (questions & expected).present?
  end

  test "should list only notes in notes view" do
    tag = tags(:test)
    get :show, id: tag.name
    notes = assigns(:notes)
    expected = [node(:one)]
    assert_not_nil assigns(:notes)
    assert (notes & expected).present?
  end

  test "should have active Research tab for notes" do
    tag = tags(:test)
    get :show, id: tag.name
    assert_select 'ul.nav-tabs' do
      assert_select 'li.active' do
        assert_select "a[href = '/tag/test']", 1
      end
    end
    assert_select '#notes.active', 1
  end

  test "should have active question tab for question" do
    tag = tags(:question)
    get :show, id: tag.name
    assert_select 'ul.nav-tabs' do
      assert_select 'li.active' do
        assert_select "a[href = '/questions/tag/question:spectrometer']", 1
      end
    end
    assert_select '#questions.active', 1
  end
  
  test "should choose I18n for tag controller" do
    available_testing_locales.each do |lang|
        old_controller = @controller
        @controller = SettingsController.new
        
        get :change_locale, :locale => lang.to_s
        
        @controller = old_controller
        
        UserSession.create(rusers(:bob))
        post :create, :name => 'mytag', :nid => node(:one).nid, :uid => rusers(:bob)
        post :create, :name => 'mytag', :nid => node(:one).nid, :uid => rusers(:bob)
        assert_equal I18n.t('tag_controller.tag_already_exists'), assigns['output']['errors'][0]
    end
  end
end
