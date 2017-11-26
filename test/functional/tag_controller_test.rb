# def delete
# def contributors_index

require 'test_helper'

class TagControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  # create accepts comma-delimited list of tags
  test 'add one or two tags' do
    UserSession.create(rusers(:bob))

    post :create, name: 'mytag', nid: node(:one).nid, uid: rusers(:bob).id

    assert_equal 'mytag', assigns[:tags].last.name
    assert_redirected_to(node(:one).path)

    post :create,
         name: 'mysecondtag,mythirdtag',
         nid: node(:one).nid,
         uid: rusers(:bob).id

    assert_equal 'mysecondtag', assigns[:tags][assigns[:tags].length - 2].name
    assert_equal 'mythirdtag', assigns[:tags].last.name
    assert_redirected_to(node(:one).path)

    xhr :post, :create, name: 'myfourthtag,myfifthtag', nid: node(:one).nid, uid: rusers(:bob).id

    assert_response :success
    assert_equal [['myfourthtag', Tag.find_by_name('myfourthtag').tid], ['myfifthtag', Tag.find_by_name('myfifthtag').tid]], JSON.parse(response.body)['saved']
  end

  test 'validate unused tag' do
    UserSession.create(rusers(:bob))

    get :contributors,
        id: 'question:*'

    assert_template :contributors
    assert_tag tag: 'p',
               child: /No contributors for that tag/
  end

  test "won't add invalid tags" do
    UserSession.create(rusers(:bob))

    post :create,
         name: 'my invalid tag $_',
         nid: node(:one).nid

    assert_redirected_to(node(:one).path)
    assert_equal 'Error: tags can only include letters, numbers, and dashes', assigns[:output][:errors][0]
  end

  test "won't add disallowed tags" do
    UserSession.create(rusers(:bob))

    post :create,
         name: 'with:bob',
         nid: node(:one).nid # authored by jeff, not bob

    assert_redirected_to(node(:one).path)
    assert_equal I18n.t('node.only_author_use_powertag'), assigns[:output][:errors][0]
  end

  test 'admins can add disallowed tags' do
    UserSession.create(rusers(:admin))

    post :create,
         name: 'with:bob',
         nid: node(:one).nid # authored by jeff, not bob

    assert_redirected_to(node(:one).path)
    assert_equal 0, assigns[:output][:errors].length
  end

  # create returns JSON list of errors in response[:errors]
  test 'add duplicate tag' do
    UserSession.create(rusers(:bob))

    post :create,
         name: 'mytag',
         nid: node(:one).nid,
         uid: rusers(:bob)

    assert_redirected_to(node(:one).path)

    # 2nd identical tag:

    post :create,
         name: 'mytag',
         nid: node(:one).nid,
         uid: rusers(:bob)

    assert_redirected_to(node(:one).path)
    assert_equal 'Error: that tag already exists.', assigns[:output][:errors][0]
  end

  test 'add tag not logged in' do
    post :create,
         name: 'mytag',
         nid: node(:one).nid,
         uid: 1

    assert_redirected_to('/login')
  end

  test 'tag index' do
    get :index

    assert :success
    assert_equal assigns['tags'].sort_by(&:count).sort_by(&:tid) , assigns['tags'].sort_by(&:tid)
    assert_equal assigns['tags'].collect(&:name), assigns['tags'].collect(&:name).uniq
    assert_not assigns['tags'].collect(&:node).flatten.collect(&:status).include?(0)
    assert_not_nil :tags
  end

  test 'tag show' do
    get :show, id: tags(:spectrometer).name

    assert :success
    assert_not_nil :tags

    assert_equal tags(:spectrometer).parent, 'spectrometry'
    # iterate through results
    assert !assigns['notes'].empty?
    assigns['notes'].each do |node|
      assert node.has_tag('spectrometry') # should return false
      assert_not node.has_tag_without_aliasing('spectrometry') # should return false
    end

    # assert_equal assigns['tags'].length, 1
    assert_select '#wiki-content', 1
  end

  test 'tag show JSON' do
    get :show, id: tags(:spectrometer).name, format: 'json'

    assert :success
    assert_not_nil :tags

    json = ActiveSupport::JSON.decode(@response.body)

    assert_not_nil json
    assert !assigns['notes'].empty?
    node = Node.find tags(:spectrometer).nodes.first.nid
    assert_equal node.nid,                  json.first['nid']
    assert_equal node.body_preview,         json.first['preview']
    assert_equal node.main_image,           json.first['image'] # this won't check anything bc there is no main image
    assert_equal node.tags.collect(&:name), json.first['tags']
  end

  test 'wildcard tag show' do
    get :show, id: 'question:*'
    assert :success
    assert_not_nil :tags
    assert :wildcard

    assert_select '#note-graph', 0
  end

  test "wildcard tag show wiki pages" do
    get :show, id: 'activities:*', node_type: 'wiki'
    assert :success
    assert_not_nil :tags
    assert :wildcard
    assert :wikis
    assert assigns(:wikis).length > 0

    assert_select '#note-graph', 0
  end

  test "wildcard does not show wiki" do
    get :show, id: 'question:*', node_type: 'wiki'
    assert_equal true, assigns(:wikis).empty?
  end

  test "should show a featured wiki page at top, if it exists" do
    tag = tags(:test)

    get :show, id: node(:organizers).slug

    assert_select '#wiki-content', 1
  end

  test 'tag widget' do
    get :widget, id: Tag.last.name
    assert :success
    assert_not_nil :notes
  end

  test 'tag blog' do
    get :blog, id: Tag.last.name

    assert :success
    assert_not_nil :notes
    assert_not_nil :tags
  end

  test 'tag author' do
    get :author, id: User.last.username

    assert :success
  end

  test 'tag rss' do
    get :rss, tagname: Tag.last.name, format: 'rss'

    assert :success
    assert_not_nil :notes
  end

  test 'tag contributors' do
    get :contributors, id: Tag.last.name

    assert :success
    assert_not_nil :notes
    assert_not_nil :users
    assert_not_nil :tag
  end

  test 'adds comment when awarding a barnstar' do
    ApplicationController.any_instance.stubs(:current_user).returns(User.first)
    assert_difference 'Comment.count' do
      node = Node.where(type: 'note').last

      post :barnstar,
           nid: node.nid,
           star: 'basic'

      assert_equal "[@#{User.first.username}](/profile/#{User.first.username}) awards a <a href=\"//#{request.host}/wiki/barnstars\">barnstar</a> to #{node.author.name} for their awesome contribution!", Comment.last.body
    end
  end

  test 'should take node type as question if tag is a question tag' do
    tag = tags(:question)

    get :show, id: tag.name

    assert_equal 'questions', assigns(:node_type)
  end

  test 'should take node type as note if tag is not a question tag' do
    tag = tags(:awesome)

    get :show, id: tag.name

    assert_equal 'note', assigns(:node_type)
  end

  test 'should list only question in question view' do
    tag = tags(:question)

    get :show, id: tag.name

    questions = assigns(:questions)
    expected = [node(:question), node(:question2)]
    assert_not_nil assigns(:questions)
    assert (questions & expected).present?
  end

  test 'should list only notes in notes view' do
    tag = tags(:test)

    get :show, id: tag.name

    notes = assigns(:notes)
    expected = [node(:one)]
    assert_not_nil assigns(:notes)
    assert (notes & expected).present?
  end

  test 'should have active Research tab for notes' do
    tag = tags(:test)

    get :show, id: tag.name

    assert_select 'ul.nav-tabs' do
      assert_select 'li.active' do
        assert_select "a[href = '/tag/test']", 1
      end
    end
    assert_select '#notes.active', 1
  end

  test 'should have active question tab for question' do
    tag = tags(:question)

    get :show, id: tag.name

    assert_select 'ul.nav-tabs' do
      assert_select 'li.active' do
        assert_select "a[href = '/questions/tag/question:spectrometer']", 1
      end
    end
    assert_select '#questions.active', 1
  end

  test 'can create tag instance (community_tag) using a parent tag' do
    UserSession.create(rusers(:bob))

    post :create, name: 'spectrometry', nid: node(:one).nid, uid: rusers(:bob).id

    assert_equal 'spectrometry', assigns[:tags].last.name
    assert_redirected_to(node(:one).path)
  end

  test 'shows things tagged with child tag' do
    tag = tags(:spectrometer)
    tag.parent = 'spectrometry'
    tag.save
    tag2 = tags(:spectrometry)
    tag2.parent = ''
    tag2.save

    assert_equal 'spectrometry', tag.parent
    assert_equal '',             tag2.parent
    node(:blog).add_tag('spectrometry', rusers(:bob))
    assert node(:blog).has_tag_without_aliasing('spectrometry')

    get :show, id: 'spectrometry'

    # order of timestamps during testing (almost same timestamps) was causing testing irregularities
    notes = assigns(:notes).sort_by(&:title).reverse

    assert_equal 2, notes.length
    assert_equal [1, 13], notes.collect(&:nid)
    assert_equal [node(:one).title, 'Blog post'], notes.collect(&:title)

    # should be the first node, nid=1
    assert_equal node(:one).title, notes.first.title
    assert_equal ['spectrometer'], notes.first.tags.collect(&:name)
    assert       notes.first.has_tag_without_aliasing('spectrometer')
    assert_not notes.first.has_tag_without_aliasing('spectrometry')

    # should be the blog node, nid=13
    assert_equal 'Blog post', notes.last.title
    assert_equal ['spectrometry'], notes.last.tags.collect(&:name)
    assert_not notes.last.has_tag_without_aliasing('spectrometer')
    assert       notes.last.has_tag_without_aliasing('spectrometry')
  end

  test 'does not show things tagged with parent tag' do
    tag = tags(:spectrometer)
    tag.parent = 'spectrometry'
    tag.save
    tag2 = tags(:spectrometry)
    tag2.parent = ''
    tag2.save
    assert_equal 'spectrometry', tags(:spectrometer).parent
    assert_equal '',             tags(:spectrometry).parent
    node(:blog).add_tag('spectrometry', rusers(:bob))

    get :show, id: 'spectrometer'

    assert_equal 1, assigns(:notes).length
    assert_not assigns(:notes).first.has_tag_without_aliasing('spectrometry')
    assert       assigns(:notes).first.has_tag_without_aliasing('spectrometer')
  end

  test 'shows suggested tags' do
    get :suggested, id: 'spectr'

    assert_equal 4, assigns(:suggestions).length
    assert_equal ['question:spectrometer', 'spectrometer', 'activity:spectrometer', 'activities:spectrometer'], JSON.parse(response.body)
  end

  test 'should choose I18n for tag controller' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, locale: lang.to_s

      @controller = old_controller

      UserSession.create(rusers(:bob))
      post :create, name: 'mytag', nid: node(:one).nid, uid: rusers(:bob)
      post :create, name: 'mytag', nid: node(:one).nid, uid: rusers(:bob)
      assert_equal I18n.t('tag_controller.tag_already_exists'), assigns[:output][:errors][0]
    end
  end

  test 'shows embeddable grid of tagged content' do
    get :gridsEmbed, tagname: 'spectrometer'

    assert_response :success
    assert_select 'table' # ensure a table is shown
  end
end
