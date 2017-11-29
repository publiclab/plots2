require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  def setup
    Timecop.freeze # account for timestamp change
    activate_authlogic
  end

  def teardown
    Timecop.return
  end

  test 'redirect note short url' do
    note = Node.where(type: 'note', status: 1).first

    get :shortlink, id: note.id

    assert_redirected_to note.path
  end

  test 'show note by id' do
    note = Node.where(type: 'note', status: 1).first
    assert_not_nil note.id

    get :show, id: note.id

    assert_response :success
  end

  test 'show note' do
    note = nodes(:blog)
    note.add_tag('activity:nonexistent', note.author) # testing responses display
    assert_equal 'nonexistent', note.power_tag('activity')

    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize

    assert_response :success
    assert_select '#other-activities', false
  end

  test 'notes record views with unique ips' do
    note = nodes(:blog)
    # clear impressions so we get a unique view
    Impression.delete_all
    assert_equal 0, note.views
    assert_equal 0, Impression.count

    # this assertion didn't work due to a bug in:
    # https://github.com/publiclab/plots2/issues/1196
    # assert_difference 'note.views', 1 do
    assert_difference 'Impression.count', 1 do
      get :show,
          author: note.author.name,
          date: Time.at(note.created).strftime('%m-%d-%Y'),
          id: note.title.parameterize
    end

    assert_equal '0.0.0.0', Impression.last.ip_address
    Impression.last.update_attribute('ip_address', '0.0.0.1')

    assert_difference 'note.totalviews', 1 do
      get :show,
          author: note.author.name,
          date: Time.at(note.created).strftime('%m-%d-%Y'),
          id: note.title.parameterize
    end

    assert_equal 2, note.totalviews

    # same IP won't add to views twice
    assert_difference 'note.totalviews', 0 do
      get :show,
          author: note.author.name,
          date: Time.at(note.created).strftime('%m-%d-%Y'),
          id: note.title.parameterize
    end
  end

  test 'redirect normal user to tagged blog page' do
    note = nodes(:one)
    blog = nodes(:blog)
    note.add_tag("redirect:#{blog.nid}", users(:jeff))
    assert_equal blog.nid.to_s, note.power_tag('redirect')

    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize

    assert_redirected_to blog.path
  end

  test 'admins and moderators view redirect-tagged notes with flash warning' do
    note = nodes(:one)
    blog = nodes(:blog)
    note.add_tag("redirect:#{blog.nid}", users(:jeff))
    assert_equal blog.nid.to_s, note.power_tag('redirect')
    UserSession.find.destroy if UserSession.find
    UserSession.create(users(:jeff))

    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize

    assert_response :success
    assert_equal "Only moderators and admins see this page, as it is redirected to #{blog.title}.
        To remove the redirect, delete the tag beginning with 'redirect:'", flash[:warning]
    UserSession.find.destroy
  end

  test 'show note with Browse other activities link' do
    note = Node.where(type: 'note', status: 1).first
    note.add_tag('activity:spectrometer', note.author) # testing responses display
    assert !Tag.where(name: 'activities:' + note.power_tag('activity')).empty?

    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize

    assert_response :success
    assert_select '#other-activities'
    assert_select "a#other-activities[href = '/wiki/spectrometer']", 1
  end

  test "don't show note by spam author" do
    note = nodes(:spam) # spam fixture

    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize

    assert_redirected_to '/'
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil :notes
  end

  test 'should get raw note markup' do
    id = Node.where(type: 'note', status: 1).last.id

    get :raw, id: id

    assert_response :success
  end

  test 'should show main image for node, returning blank image if it has none' do
    node = nodes(:one)

    get :image, id: node.id

    assert_response :redirect
    assert_redirected_to 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
  end

  test 'should get tools' do
    get :tools

    assert_response :redirect
    assert_redirected_to '/methods'
  end

  test 'should get places' do
    get :places

    assert_response :success
    assert_not_nil :notes
  end

  test 'post note no login' do
    # kind of weird, to successfully log out, we seem to have to first log in to get the UserSession...
    user_session = UserSession.create(users(:bob))
    user_session.destroy
    title = 'My new post about balloon mapping'

    post :create,
         id: users(:bob).id,
         title: title,
         body: 'This is a fascinating post about a balloon mapping event.',
         tags: 'balloon-mapping,event'
    # , main_image: "/images/testimage.jpg"

    assert_redirected_to('/login')
  end

  test 'non-first-timer posts note' do
    UserSession.create(users(:jeff))
    title = 'My new post about balloon mapping'
    assert !users(:jeff).first_time_poster
    assert User.where(role: 'moderator').count > 0

    assert_difference 'ActionMailer::Base.deliveries.size', User.where(role: 'moderator').count do
      post :create,
           title: title,
           body:  'This is a fascinating post about a balloon mapping event.',
           tags:  'balloon-mapping,event'
      # , main_image: "/images/testimage.jpg"
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal '[PublicLab] ' + title, email.subject
    assert_equal 1, Node.last.status
    assert_redirected_to '/notes/' + users(:jeff).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
  end

  test 'first-timer posts note' do
    UserSession.create(users(:lurker))
    title = 'My first post to Public Lab'

    post :create,
         title: title,
         body: 'This is a fascinating post about a balloon mapping event.',
         tags: 'balloon-mapping,event'
    # , :main_image => "/images/testimage.jpg"

    assert_equal "Success! Thank you for contributing open research, and thanks for your patience while your post is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so.", flash[:notice]
    assert_nil flash[:warning] # no double notice
    assert_equal 4, Node.last.status
    assert_equal title, Node.last.title
    assert_redirected_to '/notes/' + users(:lurker).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
  end

  test 'first-timer moderated note (status=4) hidden to normal users on research note feed' do
    node = nodes(:first_timer_note)
    assert_equal 4, node.status

    get :index

    assert_select ".note-nid-#{node.id}", false
  end

  test 'first-timer moderated note (status=4) hidden to normal users in full view' do
    node = nodes(:first_timer_note)
    assert_equal 4, node.status

    get :show,
        author: node.author.username,
        date: node.created_at.strftime('%m-%d-%Y'),
        id: node.title.parameterize

    assert_redirected_to '/'
  end

  test 'first-timer moderated note (status=4) shown to author in full view with notice' do
    node = nodes(:first_timer_note)
    UserSession.create(node.author.user)
    assert_equal 4, node.status

    get :show,
        author: node.author.username,
        date: node.created_at.strftime('%m-%d-%Y'),
        id: node.title.parameterize

    assert_response :success
    assert_equal "Thank you for contributing open research, and thanks for your patience while your post is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so.", flash[:warning]
  end

  test 'first-timer moderated note (status=4) shown to author in list view with notice' do
    node = nodes(:first_timer_note)
    UserSession.create(node.author.user)
    assert_equal 4, node.status

    get :index

    assert_response :success
    assert_select 'div.note'
    assert_select "div.note-nid-#{node.nid} p.moderated", 'Pending approval by community moderators. Please be patient!'
  end

  test 'first-timer moderated note (status=4) shown to moderator with notice and approval prompt in full view' do
    UserSession.create(users(:moderator))
    node = nodes(:first_timer_note)
    assert_equal 4, node.status

    get :show,
        author: node.author.username,
        date: node.created_at.strftime('%m-%d-%Y'),
        id: node.title.parameterize

    assert_response :success
    assert_equal "First-time poster <a href='#{node.author.name}'>#{node.author.name}</a> submitted this #{time_ago_in_words(node.created_at)} ago and it has not yet been approved by a moderator. <a class='btn btn-default btn-sm' href='/moderate/publish/#{node.id}'>Approve</a> <a class='btn btn-default btn-sm' href='/moderate/spam/#{node.id}'>Spam</a>", flash[:warning]
  end

  test 'first-timer moderated note (status=4) shown to moderator with notice and approval prompt in list view' do
    UserSession.create(users(:moderator))
    node = nodes(:first_timer_note)
    assert_equal 4, node.status

    get :index

    assert_response :success
    assert_select 'div.note'
    assert_select "div.note-nid-#{node.nid} p.moderated", "Moderate first-time post: \n              Approve\n              Spam"
  end

  test 'post_note_error_no_title' do
    UserSession.create(users(:bob))

    post :create,
         body: 'This is a fascinating post about a balloon mapping event.',
         tags: 'balloon-mapping,event'

    assert_template 'editor/post'
    assert_select '.alert'
  end

  test 'posting note successfully with no errors using xhr (rich editor)' do
    UserSession.create(users(:bob))

    xhr :post,
        :create,
        body: 'This is a fascinating post about a balloon mapping event.',
        title: 'A completely unique snowflake',
        tags: 'balloon-mapping,event'

    assert_response :success
    assert_not_nil @response.body
    assert_equal '/notes/Bob/' + Time.now.strftime('%m-%d-%Y') + '/a-completely-unique-snowflake', @response.body
  end
  
  test 'post_note_error_no_title_xhr' do
    UserSession.create(users(:bob))

    xhr :post,
        :create,
        body: 'This is a fascinating post about a balloon mapping event.',
        tags: 'balloon-mapping,event'

    assert_response :success
    assert_not_nil @response.body
    json = JSON.parse(@response.body)
    assert_equal ["can't be blank"], json['title']
    assert !json['title'].empty?
  end

  test 'posting note with an error using xhr (rich editor) returns a JSON error' do
    UserSession.create(users(:bob))

    xhr :post,
        :create,
        body: 'This is a fascinating post about a balloon mapping event.',
        title: '',
        tags: 'balloon-mapping,event'

    assert_response :success
    assert_not_nil @response.body
    assert_equal "{\"title\":[\"can't be blank\"],\"path\":[\"This title has already been taken\"]}", @response.body
  end

  test 'returning json errors on xhr note update' do
    user = UserSession.create(users(:jeff))

    xhr :post,
        :update,
        id: nodes(:blog).id,
        title: ''

    assert_response :success
    assert_not_nil @response.body
    json = JSON.parse(@response.body)
    assert !json['title'].empty?
  end

  # def test_cannot_delete_post_if_not_yours

  # end

  test 'should load iframe url in comments' do
    comment = Comment.new(nid: nodes(:one).nid,
                          uid: users(:bob).id,
                          thread: '01/')
    comment.comment = '<iframe src="http://mapknitter.org/embed/sattelite-imagery" style="border:0;"></iframe>'
    comment.save
    node = nodes(:one).path.split('/')

    get :show, id: node[4], author: node[2], date: node[3]

    assert_tag tag: 'iframe', attributes: { src: 'http://mapknitter.org/embed/sattelite-imagery' }
  end

  # test "should mark admins and moderators with a special icon" do
  #   node = nodes(:one)
  #   get :show,
  #       author: node.author.username,
  #       date: node.created_at.strftime("%m-%d-%Y"),
  #       id: node.title.parameterize
  #   assert_select "i[title='Admin']", 1
  #   assert_select "i[title='Moderator']", 1
  # end

  test 'should display an icon for users with streak longer than 7 days' do
    node = nodes(:one)
    User.any_instance.stubs(:note_streak).returns([8, 10])
    User.any_instance.stubs(:wiki_edit_streak).returns([9, 15])
    User.any_instance.stubs(:comment_streak).returns([10, 30])
    get :show,
        author: node.author.username,
        date: node.created_at.strftime('%m-%d-%Y'),
        id: node.title.parameterize
    assert_select '.fa-fire', 3
  end

  test 'should redirect to questions show page after creating a new question' do
    user = UserSession.create(users(:bob))
    title = 'How to use Spectrometer'
    post :create,
         title: title,
         body: 'Spectrometer question',
         tags: 'question:spectrometer',
         redirect: 'question'

    assert_redirected_to '/questions/' + users(:bob).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
    assert_equal "Success! Thank you for contributing with a question, and thanks for your patience while your question is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published.", flash[:notice]
  end

  test 'non-first-timer posts a question' do
    UserSession.create(users(:jeff))
    title = 'My first question to Public Lab'
    post :create,
         title: title,
         body: 'Spectrometer question',
         tags: 'question:spectrometer',
         redirect: 'question'

    assert_redirected_to '/questions/' + users(:jeff).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
    assert_equal flash[:notice], 'Question published. In the meantime, if you have more to contribute, feel free to do so.'
  end

  test 'should display /post template when editing a note in legacy mode' do
    user = UserSession.create(users(:jeff))
    note = nodes(:blog)
    post :edit,
         id: note.nid,
         legacy: true
    assert_response :success
    assert_select 'input#taginput[value=?]', note.tagnames.join(',')
  end

  test 'should display /post template when editing a question in legacy mode' do
    user = UserSession.create(users(:jeff))
    note = nodes(:question)
    note.add_tag('nice', users(:jeff))
    post :edit,
         id: note.nid,
         legacy: true
    assert_response :success
    assert_select 'input#taginput[value=?]', note.tagnames.join(',') + ',spectrometer' # for now, question subject is appended to end of form
  end

  test 'should display /post template when editing a note' do
    user = UserSession.create(users(:jeff))
    note = nodes(:blog)
    post :edit,
         id: note.nid
    assert_response :success
    assert_select 'input.form-control.input-lg[value=?]', note.tagnames.join(',')
  end

  test 'should display /post template when editing a question' do
    user = UserSession.create(users(:jeff))
    note = nodes(:question)
    note.add_tag('nice', users(:jeff))
    post :edit,
         id: note.nid
    assert_response :success
    assert_select 'input.form-control.input-lg[value=?]', note.tagnames.join(',')
  end

  test 'should redirect to questions show page when editing an existing question' do
    user = UserSession.create(users(:jeff))
    note = nodes(:question)
    post :update,
         id: note.nid,
         title: note.title,
         body: 'Spectrometer doubts',
         tags: 'question:spectrometer',
         redirect: 'question'

    assert_redirected_to note.path(:question) + '?_=' + Time.now.to_i.to_s
  end

  test 'should update a former note that has become a question by tagging' do
    node = nodes(:blog)
    node.add_tag('question:foo', users(:bob))

    post :update,
         id: node.nid,
         title: node.title + ' amended'

    assert_response :redirect
  end

  test 'should redirect to question path if node is a question when visiting shortlink' do
    node = nodes(:question)
    get :shortlink, id: node.id
    assert_redirected_to node.path(:question)
  end

  test 'should redirect to question path if node is a question when visiting show path' do
    note = nodes(:question)

    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize
    assert_redirected_to note.path(:question)
  end

  test 'should list only research notes with status 1 in index' do
    get :index
    notes = assigns(:notes)
    expected = [nodes(:one)]
    questions = [nodes(:question)]
    assert (notes & expected).present?
    assert !(notes & questions).present?
  end

  test 'should list research notes with status 1 & 4 in index if admin is logged in' do
    UserSession.create(users(:admin))
    get :index
    notes = assigns(:notes)
    expected = [nodes(:one), nodes(:first_timer_note)]
    questions = [nodes(:question)]
    assert (notes & expected).present?
    assert !(notes & questions).present?
  end

  test 'should list only research notes with status 1 in popular' do
    UserSession.create(users(:admin))
    get :popular
    notes = assigns(:notes)
    expected = [nodes(:one)]
    questions = [nodes(:question)]
    assert (notes & expected).present?
    assert !(notes & questions).present?
  end

  test 'should list only research notes with status 1 in liked' do
    UserSession.create(users(:admin))
    get :liked
    notes = assigns(:notes)
    expected = [nodes(:one)]
    questions = [nodes(:question)]
    assert (notes & expected).present?
    assert !(notes & questions).present?
  end

  test 'should choose I18n for notes controller' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, locale: lang.to_s

      @controller = old_controller

      UserSession.create(users(:jeff))
      title = 'Some post to Public Lab'

      post :create,
           title: title + lang.to_s,
           body: 'Some text.',
           tags: 'event'

      assert_equal I18n.t('notes_controller.research_note_published'), flash[:notice]
    end
  end
end
