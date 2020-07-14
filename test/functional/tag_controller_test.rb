require 'test_helper'

class TagControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  # create accepts comma-delimited list of tags
  test 'add one or two tags' do
    UserSession.create(users(:bob))

    post :create, params: { name: 'mytag', nid: nodes(:one).nid, uid: users(:bob).id }

    assert_equal 'mytag', assigns[:tags].last.name
    assert_redirected_to(nodes(:one).path)

    post :create,
         params: {
         name: 'mysecondtag,mythirdtag',
         nid: nodes(:one).nid,
         uid: users(:bob).id
         }

    assert_equal 'mysecondtag', assigns[:tags][assigns[:tags].length - 2].name
    assert_equal 'mythirdtag', assigns[:tags].last.name
    assert_redirected_to(nodes(:one).path)

    post :create, params: { name: 'myfourthtag,myfifthtag', nid: nodes(:one).nid, uid: users(:bob).id }, xhr: true

    assert_response :success
    assert_equal [['myfourthtag', Tag.find_by_name('myfourthtag').tid, nodes(:one).nid.to_s], ['myfifthtag', Tag.find_by_name('myfifthtag').tid, nodes(:one).nid.to_s]], JSON.parse(response.body)['saved']
  end

  test 'check tag show page and confirm pinned post' do
    UserSession.create(users(:bob))

    # add a "pin" tag so this post should appear first
    nodes(:activity).add_tag('pin:blog', users(:bob))
    get :show,
        params: {
          id: 'blog'
        }

    assert_template :show
    assert assigns[:notes]
    assert assigns[:pinned_nodes]
    assert assigns[:pinned_nodes].first.has_tag('pin:blog')
    assert_response :success
  end

  test 'validate unused tag' do
    UserSession.create(users(:bob))

    get :show,
        params: {
          node_type: 'contributors',
          id: 'question:*'
        }

    assert_select 'h3', text: 'Contributors for question:*'
  end

  test "won't add invalid tags" do
    UserSession.create(users(:bob))

    post :create,
         params: {
         name: 'my invalid tag $_',
         nid: nodes(:one).nid
         }

    assert_redirected_to(nodes(:one).path)
    assert_equal 'Error: tags can only include letters, numbers, and dashes', assigns[:output][:errors][0]
  end

  test "won't add disallowed tags" do
    UserSession.create(users(:bob))

    post :create,
         params: {
         name: 'with:bob',
         nid: nodes(:one).nid # authored by jeff, not bob
         }

    assert_redirected_to(nodes(:one).path)
    assert_equal I18n.t('node.only_author_use_powertag'), assigns[:output][:errors][0]
  end

  test 'admins can add disallowed tags' do
    UserSession.create(users(:admin))

    post :create,
         params: {
         name: 'with:bob',
         nid: nodes(:one).nid # authored by jeff, not bob
         }

    assert_redirected_to(nodes(:one).path)
    assert_equal 0, assigns[:output][:errors].length
  end

  # create returns JSON list of errors in response[:errors]
  test 'add duplicate tag' do
    UserSession.create(users(:bob))

    post :create,
         params: {
         name: 'mytag',
         nid: nodes(:one).nid,
         uid: users(:bob)
         }

    assert_redirected_to(nodes(:one).path)

    # 2nd identical tag:

    post :create,
         params: {
         name: 'mytag',
         nid: nodes(:one).nid,
         uid: users(:bob)
         }

    assert_redirected_to(nodes(:one).path)
    assert_equal 'Error: that tag already exists.', assigns[:output][:errors][0]
  end

  test 'add tag not logged in' do
    post :create,
         params: {
         name: 'mytag',
         nid: nodes(:one).nid,
         uid: 1
         }

    assert_redirected_to('/login?return_to=/tag/create/1')
  end

  test 'related tags' do
    get :related,
        params: {
        id: 'test'
        }

    assert :success
    assert_not_nil :tags
  end

  test 'tag index' do
    get :index

    assert :success
    assert_equal assigns['tags'].sort_by(&:count).sort_by(&:tid) , assigns['tags'].sort_by(&:tid)
    assert_equal assigns['tags'].collect(&:name), assigns['tags'].collect(&:name).uniq
    assert_not assigns['tags'].collect(&:node).flatten.collect(&:status).include?(0)
    assert_not_nil :tags
  end

  test 'tag search' do
    get :index , params: { search: "featured" }

    assert :success
    assert assigns(:tags).length > 0
    assert_template 'tag/index'
  end

  test 'tags in asc order' do
    get :index, params: {sort: 'name', order: 'asc' }
    assert :success
    assert assigns(:tags).each_cons(2).all?{|i,j| j.name >= i.name}
  end

  test 'tags in desc order' do
    get :index, params: {sort: 'name', order: 'desc' }
    assert :success
    assert assigns(:tags).each_cons(2).all?{|i,j| j.name <= i.name}
  end

  test 'tag show' do
    get :show, params: { id: tags(:spectrometer).name }

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
    assert_select '#wiki-summary', 1
  end

  test 'show page for non-existent tag' do
    get :show, params: { id: 'nonexistent' }
    assert :success
  end

  test 'tag show, sort by views DESC' do
    get :show, params: { id: tags(:latitude).name, order: 'views' }
    views_array = assigns['notes'].map(&:views)
    sorted_views_array = views_array.sort.reverse
    assert_equal sorted_views_array, views_array
  end

  test 'tag show, sort by likes DESC' do
    get :show, params: { id: tags(:latitude).name, order: 'likes' }
    likes_array = assigns['notes'].map(&:cached_likes)
    sorted_likes_array = likes_array.sort.reverse
    assert_equal sorted_likes_array, likes_array
  end

  test 'tag show range' do
    get :show, params: { id: tags(:spectrometer).name,
               start: (Time.now - 1.day).strftime('%d-%m-%Y'),
               end: Time.now.strftime('%d-%m-%Y') }

    assert :success
    assert_not_nil :tags
  end

  test 'tag show JSON' do
    get :show, params: { id: tags(:spectrometer).name, format: 'json' }

    assert :success
    assert_not_nil :tags
    json = ActiveSupport::JSON.decode(@response.body)
    assert_not_nil json
    assert !assigns['notes'].empty?
    node = Node.find tags(:spectrometer).nodes.first.nid
    assert_equal node.nid,                  json.first['node']['nid']
    assert_equal node.body_preview,         json.first['preview']
    #assert_equal node.main_image,           json.first['image'] # this won't check anything bc there is no main image
    assert_equal node.tags.collect(&:name), json.first['tags']
  end

  test 'wildcard tag show' do
    get :show, params: { id: 'question:*' }
    assert :success
    assert_not_nil :tags
    assert :wildcard
    assert_select '#note-graph', 0
  end

  test "wildcard tag show wiki pages" do
    get :show, params: { id: 'activities:*', node_type: 'wiki' }
    assert :success
    assert_not_nil :tags
    assert :wildcard
    assert :wikis
    assert assigns(:wikis).length > 0

    assert_select '#note-graph', 0
  end

  test 'wildcard tag should list answered questions' do
    get :show, params: { id: 'question:*' }

    assert_not_nil assigns(:answered_questions)
  end

  test 'wildcard tag should have a active asked and an inactive answered tab for question' do
    get :show, params: { id: 'question:*' }

    selector = css_select '#asked-tab.active'
    assert_equal selector.size, 1
    assert_select '#answered-tab', 1
  end

  test "wildcard tag show wiki pages with author" do
    get :show_for_author, params: { node_type: 'wiki', id: 'awes*', author: 'Bob' }
    assert :success
    assert_not_nil :tags
    assert assigns(:wildcard)
    assert :wikis
    assert assigns(:wikis).length > 0
    assigns['wikis'].each do |node|
      assert_equal 1, node.uid
      assert node.has_tag('awes*')
    end
    assert_select '#note-graph', 0
    assert_template 'tag/show'
  end

  test "tag show wiki pages with author" do
    get :show, params: { node_type: 'wiki', id: 'awesome', author: 'Bob' }
    assert :success
    assert_not_nil :tags
    assert_nil assigns(:wildcard)
    assert :wikis
    assert assigns(:wikis).length > 0
    assigns['wikis'].each do |node|
      assert_equal 1, node.uid
      assert node.has_tag('awesome')
    end
    assert_template 'tag/show'
  end

  test "wildcard does not show wiki" do
    get :show, params: { id: 'question:*', node_type: 'wiki' }
    assert_equal true, assigns(:wikis).empty?
  end

  test "should show a featured wiki page at top, if it exists" do
    tag = tags(:test)

    get :show, params: { id: nodes(:organizers).slug }

    assert_select '#wiki-summary', 1
  end

  test 'show note with author and tagname without wildcard' do
    get :show_for_author, params: { id: 'test', author: 'jeff' }
    assert_response :success
    assert_not_nil :tags
    assert_not_nil :authors
    assert_not_nil :notes
    assert_nil assigns(:wildcard)
    assert  assigns['notes'].include?(nodes(:one))
    assigns['notes'].each do |node|
      assert_equal 2, node.uid
      assert node.has_tag('test')
    end
    assert_template 'tag/show'
  end

  test 'show note with author and tagname with wildcard' do
    get :show_for_author, params: { id: 'test*', author: 'jeff' }
    assert_response :success
    assert_not_nil :tags
    assert_not_nil :authors
    assert_not_nil :notes
    assert assigns(:wildcard)
    assert  assigns['notes'].include?(nodes(:one))
    assert  assigns['notes'].include?(nodes(:blog))
    assigns['notes'].each do |node|
      assert_equal 2, node.uid
      assert node.has_tag('test*')
    end
    assert_template 'tag/show'
  end

  test 'tag widget' do
    get :widget, params: { id: Tag.last.name }
    assert :success
    assert_not_nil :notes
  end

  test 'tag blog' do
    get :blog, params: { id: Tag.last.name }
    assert :success
    assert_not_nil :notes
    assert_not_nil :tags
  end

  test 'tag author' do
    get :author, params: { id: User.last.username }

    assert :success
  end

  test 'tag rss' do
    get :rss, params: { tagname: Tag.last.name, format: 'rss' }

    assert :success
    assert_not_nil :notes
  end

  test 'tag contributors' do
    get :show,
        params: {
          node_type: 'contributors',
          id: 'blog'
        }

    assert :success
    assert_not_nil :notes
    assert_not_nil :users
    assert_not_nil :tag
    selector = css_select ".users-row"
    assert_equal selector.size, assigns(:users).length
  end

  test 'adds comment when awarding a barnstar' do
    ApplicationController.any_instance.stubs(:current_user).returns(User.first)
    assert_difference 'Comment.count' do
      node = Node.where(type: 'note').last

      post :barnstar,
           params: {
           nid: node.nid,
           star: 'basic'
           }

      assert_equal "[@#{User.first.username}](/profile/#{User.first.username}) awards a <a href=\"//#{request.host}/wiki/barnstars\">barnstar</a> to #{node.author.name} for their awesome contribution!", Comment.last.body
    end
  end

  test 'adds comment when creating coauthor' do
    UserSession.create(users(:jeff))
    user = users(:bob)
    node = nodes(:one)

    assert_difference 'Comment.count' do
      tagname = "with:#{user.name}"
      post :create,
           params: {
           name: tagname,
           nid: node.id
           }

      assert_equal " [@#{node.author.name}](/profile/#{node.author.name}) has marked [@#{tagname.split(':')[1]}](/profile/#{tagname.split(':')[1]}) as a co-author. ", Comment.last.body
    end
  end

  test 'should take node type as question if tag is a question tag' do
    tag = tags(:question)

    get :show, params: { id: tag.name }

    assert_equal 'questions', assigns(:node_type)
  end

  test 'should take node type as note if tag is not a question tag' do
    tag = tags(:awesome)

    get :show, params: { id: tag.name }

    assert_equal 'note', assigns(:node_type)
  end

  test 'should list only question in question view' do
    tag = tags(:question)

    get :show, params: { id: tag.name }

    questions = assigns(:questions)
    expected = [nodes(:question), nodes(:question2)]
    assert_not_nil assigns(:questions)
    assert (questions & expected).present?
  end

  test 'should list only notes in notes view' do
    tag = tags(:test)

    get :show, params: { id: tag.name }

    notes = assigns(:notes)
    expected = [nodes(:one)]
    assert_not_nil assigns(:notes)
    assert (notes & expected).present?
  end

  test 'can create tag instance (community_tag) using a parent tag' do
    UserSession.create(users(:bob))

    post :create, params: { name: 'spectrometry', nid: nodes(:one).nid, uid: users(:bob).id }

    assert_equal 'spectrometry', assigns[:tags].last.name
    assert_redirected_to(nodes(:one).path)
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
    nodes(:blog).add_tag('spectrometry', users(:bob))
    assert nodes(:blog).has_tag_without_aliasing('spectrometry')

    get :show, params: { id: 'spectrometry' }

    # order of timestamps during testing (almost same timestamps) was causing testing irregularities
    notes = assigns(:notes).sort_by(&:title).reverse

    assert_equal 2, notes.length
    assert_equal [1, 13], notes.collect(&:nid)
    assert_equal [nodes(:one).title, 'Blog post'], notes.collect(&:title)

    # should be the first node, nid=1
    assert_equal nodes(:one).title, notes.first.title
    assert_equal ['spectrometer'], notes.first.tags.collect(&:name)
    assert       notes.first.has_tag_without_aliasing('spectrometer')
    assert_not notes.first.has_tag_without_aliasing('spectrometry')

    # should be the blog node, nid=13
    assert_equal 'Blog post', notes.last.title
    assert_equal ['spectrometry'], notes.last.tags.collect(&:name)
    assert_not notes.last.has_tag_without_aliasing('spectrometer')
    assert notes.last.has_tag_without_aliasing('spectrometry')
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
    nodes(:blog).add_tag('spectrometry', users(:bob))

    get :show, params: { id: 'spectrometer' }

    assert_equal 1, assigns(:notes).length
    assert_not assigns(:notes).first.has_tag_without_aliasing('spectrometry')
    assert       assigns(:notes).first.has_tag_without_aliasing('spectrometer')
  end

  test 'shows suggested tags' do
    get :suggested, params: { id: 'spectr' }

    assert_equal 4, assigns(:suggestions).length
    assert_equal ['question:spectrometer', 'spectrometer', 'activity:spectrometer', 'activities:spectrometer'], JSON.parse(response.body)
  end

  test 'should choose I18n for tag controller' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, params: { locale: lang.to_s }

      @controller = old_controller

      UserSession.create(users(:bob))
      post :create, params: { name: 'mytag', nid: nodes(:one).nid, uid: users(:bob) }
      post :create, params: { name: 'mytag', nid: nodes(:one).nid, uid: users(:bob) }
      assert_equal I18n.t('tag_controller.tag_already_exists'), assigns[:output][:errors][0]
    end
  end

  test 'shows embeddable grid of tagged content' do
    get :gridsEmbed, params: { tagname: 'spectrometer' }

    assert_response :success
    assert_select 'table' # ensure a table is shown
  end

  test 'shows embeddable grid of tagged content with powertag' do
    get :gridsEmbed, params: { tagname: 'nodes:awesome' }

    assert_response :success
    assert_select 'table' # ensure a table is shown
    assert_equal 4, css_select('tr').length # ensure it has 4 rows
  end

  test 'rss with tagname and authorname' do
    get :rss_for_tagged_with_author, params: { tagname: 'test*', authorname: 'jeff', format: 'rss' }
    assert :success
    assert_not_nil :notes
    assert_equal 'application/xml', @response.content_type
  end

  test 'should have active question tab for question for show_for_author' do
    tag = tags(:question)
    get :show_for_author, params: { id: tag.name, author: 'jeff' }
    selector = css_select "a[href = '/questions/tag/question:spectrometer/author/jeff']"
    assert_equal selector.size, 1
    selector = css_select '#questions.active'
    assert_equal selector.size, 1
  end

  test 'should have a active asked and an inactive answered tab for question' do
    tag = tags(:question)

    get :show_for_author, params: { id: tag.name, author: 'jeff' }

    selector = css_select '#asked-tab.active'
    assert_equal selector.size, 1
    assert_select '#answered-tab', 1
  end

  test 'should list answered questions' do
    tag = tags(:question)

    get :show_for_author, params: { id: tag.name, author: 'jeff' }

    assert_not_nil assigns(:answered_questions)
  end

  test 'should take node type as note if tag is not a question tag for show_for_author' do
    tag = tags(:awesome)

    get :show_for_author, params: { id: tag.name, author: 'jeff' }

    assert_equal 'note', assigns(:node_type)
  end

  test "does not show wiki for show_for_author" do
    get :show_for_author, params: { id: 'question', node_type: 'wiki', author: 'jeff' }
    assert_equal true, assigns(:wikis).empty?
  end

  test "wildcard does not show wiki for show_for_author" do
    get :show_for_author, params: { id: 'question:*', node_type: 'wiki', author: 'jeff' }
    assert_equal true, assigns(:wikis).empty?
  end

  test "does not show note for show_for_author" do
    get :show_for_author, params: { id: 'question', author: 'jeff' }
    assert_equal true, assigns(:notes).empty?
  end

  test "wildcard does not show note for show_for_author" do
    get :show_for_author, params: { id: 'question:*', author: 'jeff' }
    assert_equal true, assigns(:notes).empty?
  end

  test "wildcard does not show map for show_for_author" do
    get :show_for_author, params: { id: 'question:*', node_type: 'maps', author: 'jeff' }
    assert_equal true, assigns(:nodes).empty?
  end

  test " does not show map for show_for_author" do
    get :show_for_author, params: { id: 'question', node_type: 'maps', author: 'jeff' }
    assert_equal true, assigns(:nodes).empty?
  end

  test "do not notify if tag created on unpublished node" do
    node = nodes(:first_timer_note)
    tagname = 'unpublished-note-tag'
    assert_difference 'ActionMailer::Base.deliveries.size',0 do
      node.add_tag(tagname, users(:newcomer))
    end
    assert_not ActionMailer::Base.deliveries.collect(&:subject).include?("#{node.title} (#{tagname})")
  end

  test 'should render a text/plain when a tag is deleted through post request xhr' do
    user = UserSession.create(users(:jeff))
    node_tag = node_tags(:awesome)
    post :delete, params: { nid: node_tag.nid, tid: node_tag.tid, uid: node_tag.uid}, xhr: true
    assert_equal node_tag.tid, JSON.parse(@response.body)['tid']
    assert_equal true, JSON.parse(@response.body)['status']
  end

  test 'add_parent method adds a tag parent' do
    user = UserSession.create(users(:admin))
    get :add_parent, params: { name: Tag.last.name, parent: Tag.first.name }
    assert_response :redirect
    assert_equal Tag.first.name, Tag.last.parent
    # flash[:notice] = "Tag parent added."
    # flash[:error] = "There was an error adding a tag parent."
    # redirect_to '/tag/' + @tag.name + '?_=' + Time.now.to_i.to_s
  end

  test 'add_parent method works with non-existent parent' do
    user = UserSession.create(users(:admin))
    get :add_parent, params: { name: Tag.last.name, parent: Tag.first.name }
    assert_response :redirect
    assert_equal Tag.first.name, Tag.last.parent
    get :index
    assert_response :success
  end

  test 'sort according to followers ascending' do
    get :index, params: { :sort => "followers", :order => "asc" }
    tags_array = assigns(:tags)
    followers_array = []
    tags_array.each do |i|
      followers_array << Tag.follower_count(i.name)
    end
    sorted_followers_array = followers_array.sort
    assert_equal sorted_followers_array, followers_array
  end

  test 'sort according to followers descending' do
    get :index, params: { :sort => "followers", :order => "desc" }
    tags_array = assigns(:tags)
    followers_array = []
    tags_array.each do |i|
      followers_array << Tag.follower_count(i.name)
    end
    sorted_followers_array = followers_array.sort.reverse
    assert_equal sorted_followers_array, followers_array
  end

  test 'graph data for cytoscape' do
    get :graph
    assert_response :success
  end

  test 'index should have powertags only if specified' do
    get :index
    assert_equal 0, assigns(:tags).where("name LIKE ?", "%:%").length

    get :index, params: { :powertags => 'true' }
    assert_not_equal 0, assigns(:tags).where("name LIKE ?", "%:%").length
  end

  # Bug 6855
  test 'counts match the nodes' do
    tag = tags(:sunny_day)
    get :show, params: { id: tag.name }

    assert_response :success

    counts = assigns(:counts)
    assert_equal 1, counts[:posts], "Note count should match"
    assert_equal 0, counts[:questions], "Question count should match"
    assert_equal 1, counts[:wiki], "Wiki count should match"
    assert_equal 1, assigns(:total_posts), "Total posts should match"
  end

  # Bug 6855
  test 'counts match the nodes for a parent tag' do
    tag = tags(:sun)
    get :show, params: { id: tag.name }

    assert_response :success

    counts = assigns(:counts)
    assert_equal 2, counts[:posts], "Note count should match"
    assert_equal 1, counts[:questions], "Question count should match"
    assert_equal 2, counts[:wiki], "Wiki count should match"
    assert_equal 2, assigns(:total_posts), "Total posts should match"
  end

  # Bug 6855
  test 'counts match the nodes when using a wildcard' do
    tag = tags(:sun)
    get :show, params: { id: tag.name + "*" }

    assert_response :success

    counts = assigns(:counts)
    assert_equal 2, counts[:posts], "Note count should match"
    assert_equal 0, counts[:questions], "Question count should match"
    assert_equal 2, counts[:wiki], "Wiki count should match"
    assert_equal 2, assigns(:total_posts), "Total posts should match"
  end

  test 'counts match the nodes for question node_type' do
    tag = tags(:sun)
    get :show, params: { id: tag.name, node_type: 'questions' }

    assert_response :success

    counts = assigns(:counts)
    assert_equal 2, counts[:posts], "Note count should match"
    assert_equal 1, counts[:questions], "Question count should match"
    assert_equal 2, counts[:wiki], "Wiki count should match"
    assert_equal 1, assigns(:total_posts), "Total posts should match"
  end

  test 'counts match the nodes for wiki node_type' do
    tag = tags(:sun)
    get :show, params: { id: tag.name, node_type: 'wiki' }

    assert_response :success

    counts = assigns(:counts)
    assert_equal 2, counts[:posts], "Note count should match"
    assert_equal 1, counts[:questions], "Question count should match"
    assert_equal 2, counts[:wiki], "Wiki count should match"
    assert_equal 2, assigns(:total_posts), "Total posts should match"
  end

  test 'counts match the nodes for map node type' do
    tag = tags(:sun)
    get :show, params: { id: tag.name, node_type: 'maps' }

    assert_response :success

    counts = assigns(:counts)
    assert_equal 2, counts[:posts], "Note count should match"
    assert_equal 1, counts[:questions], "Question count should match"
    assert_equal 2, counts[:wiki], "Wiki count should match"
    assert_equal 0, assigns(:total_posts), "Total posts should match"
  end
end
