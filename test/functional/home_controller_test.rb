require 'test_helper'
require 'sanitize'

class HomeControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'should get home' do
    title = I18n.t('home_controller.science_community')

    get :home
    assert_response :success
    assert_select "title", Sanitize.clean('&#127880;') + (" Public Lab: #{title}")
  end

  test 'home should redirect to dashboard if logged in' do
    UserSession.create(users(:bob))

    get :home
    assert_redirected_to dashboard_url
  end

  test 'should get research if not logged by /dashboard' do
    get :dashboard
    assert_redirected_to :research
    get :research
    assert_response :success
  end

  test 'should get research if not logged' do
    get :research
    assert_response :success
  end

  test 'should get dashboard if logged in by /research' do
    UserSession.create(users(:bob))
    get :research
    assert_redirected_to :dashboard
    get :dashboard
    assert_response :success
  end

  test 'should get dashboard if logged in' do
    UserSession.create(users(:bob))
    get :dashboard
    assert_response :success
  end

  test 'should show only unmoderated spam' do
    @wikis = Node.where(type: 'page')
    revisions = Revision.joins(:node)
                        .where('type = (?)', 'page')
                        .where('node_revisions.status = 1')
    @wikis += revisions

    get :research

    @wikis.each do |obj|
      if obj.class == Revision && obj.status == 1
        selections = css_select '.wiki'
        assert_equal 10, selections.length
      elsif obj.class == Revision && obj.status != 1
        selections = css_select '.wiki'
        assert_equal 0, selections.length
      end
    end
  end

  test 'should change i18n-locale to English' do
    I18n.locale = 'en'
    assert_equal 'en', I18n.locale.to_s
  end

  test 'should change i18n-locale to Deutsch' do
    I18n.locale = 'de'
    assert_equal 'de', I18n.locale.to_s
  end

  test 'should choose i18n for layout/alerts' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, params: { locale: lang.to_s }

      @controller = old_controller

      UserSession.create(users(:bob))
      session[:openid_return_to] = '/home'
      get :dashboard
      assert_select 'a[href=?]', "/openid/resume", I18n.t('layout._alerts.approve_or_deny') + Sanitize.clean(' &raquo;')
      assert true
    end
  end

  test 'should choose i18n for home/home' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, params: { locale: lang.to_s }

      @controller = old_controller

      get 'home'
      assert_template 'home/home'
    end
  end

  # dashboard_v2 tests
  test 'should get research if not logged by v2/dashboard' do
    get :dashboard_v2
    assert_redirected_to :research
    get :research
    assert_response :success
  end

  test 'get v2/dashboard includes a subscribed topic' do
    current_user = users(:bob)
    UserSession.create(current_user)
    subscribed_topic  = current_user.subscriptions.first.tag.name
    get :dashboard_v2
    assert_includes response.body, subscribed_topic
  end

  test 'new user v2/dashboard alert' do
    # :newcomer has their created_at value as Time.now
    current_user = users(:newcomer)
    alert = "Welcome! To improve your feed, follow the trending and featured topics linked below."
    UserSession.create(current_user)
    get :dashboard_v2
    assert_includes response.body, alert
  end

  test 'user with 3 or less subscriptions v2/dashboard alert' do
    # :olduser has their created_at value as 3.weeks.ago
    current_user = users(:olduser)
    alert = "To improve your feed, follow the trending and featured topics linked below."
    UserSession.create(current_user)
    get :dashboard_v2
    assert_includes response.body, alert
  end

  test 'topic order change after note is created v2/dashboard' do
    current_user = users(:bob)
    UserSession.create(current_user)
    get :dashboard_v2
    expected_first_topic = assigns[:tag_subscriptions].last.tag

    node = Node.create!(type: 'note', title:'Topic Order Note', uid: current_user.id, status: 1)
    Revision.create(nid: node.id, uid: current_user.id, title: node.title,  body: 'Topic order Note')
    node.add_tag(expected_first_topic.name, current_user)

    get :dashboard_v2
    expected_first_topic.reload
    new_first_topic = assigns[:tag_subscriptions].first.tag

    # In some cases, the previous first tag might still be the first tag because nodes can have multiple tags.
    # Checking the latest_activity_node ensures that the most recent activity was bumped up.
    assert_equal expected_first_topic.latest_activity_nid, new_first_topic.latest_activity_nid
  end

  test 'topic order change after wiki is created v2/dashboard' do
    current_user = users(:bob)
    UserSession.create(current_user)
    get :dashboard_v2
    expected_first_topic = assigns[:tag_subscriptions].last.tag

    node = Node.create!(type: 'wiki', title:'Topic Order Wiki', uid: current_user.id, status: 1)
    Revision.create(nid: node.id, uid: current_user.id, title: node.title,  body: 'Topic order Wiki')
    node.add_tag(expected_first_topic.name, current_user)

    get :dashboard_v2
    expected_first_topic.reload
    new_first_topic = assigns[:tag_subscriptions].first.tag

    # In some cases, the previous first tag might still be the first tag because nodes can have multiple tags.
    # Checking the latest_activity_node ensures that the most recent activity was bumped up.
    assert_equal expected_first_topic.latest_activity_nid, new_first_topic.latest_activity_nid
  end

  test 'topic order change after wiki is edited v2/dashboard' do
    current_user = users(:bob)
    UserSession.create(current_user)
    get :dashboard_v2
    # User is subscribed to :awesome node_tag which contains a wiki node
    node_tag = node_tags(:awesome2)
    expected_first_topic = assigns[:tag_subscriptions].where(tid: node_tag.tid).first.tag
    node_tag.node.latest.body = "Wiki update"

    get :dashboard_v2
    expected_first_topic.reload
    new_first_topic = assigns[:tag_subscriptions].first.tag

    # In some cases, the previous first tag might still be the first tag because nodes can have multiple tags.
    # Checking the latest_activity_node ensures that the most recent activity was bumped up.
    assert_equal expected_first_topic.latest_activity_nid, new_first_topic.latest_activity_nid
  end

  test 'topic order change after comment is created v2/dashboard' do
    current_user = users(:bob)
    UserSession.create(current_user)
    get :dashboard_v2
    expected_first_topic = assigns[:tag_subscriptions].last.tag

    node_tag = NodeTag.where(tid: expected_first_topic.tid).first
    node = node_tag.node
    node.add_comment(subject: 'node comment', uid: current_user.uid, body: 'node body')

    get :dashboard_v2
    expected_first_topic.reload
    new_first_topic = assigns[:tag_subscriptions].first.tag

    # In some cases, the previous first tag might still be the first tag because nodes can have multiple tags.
    # Checking the latest_activity_node ensures that the most recent activity was bumped up.
    assert_equal expected_first_topic.latest_activity_nid, new_first_topic.latest_activity_nid
  end
end
