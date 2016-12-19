# def index
# def tools
# def methods
# def places
# def shortlink
# def raw
# def show
# def create
# def edit
# def update
# def delete
# def author
# def author_topic
# def liked
# def popular
# def rss
# def liked_rss
# def rsvp

require 'test_helper'

class NotesControllerTest < ActionController::TestCase

  def setup
    Timecop.freeze # account for timestamp change
    activate_authlogic
  end

  def teardown
    Timecop.return
  end

  test "redirect note short url" do
    note = DrupalNode.where(type: 'note', status: 1).first

    get :shortlink, id: note.id

    assert_redirected_to note.path
  end

  test "show note by id" do
    note = DrupalNode.where(type: 'note', status: 1).first
    assert_not_nil note.id

    get :show, id: note.id

    assert_response :success
  end

  test "show note" do
    note = DrupalNode.where(type: 'note', status: 1).first

    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime("%m-%d-%Y"),
        id: note.title.parameterize

    assert_response :success
  end

  test "don't show note by spam author" do
    note = node(:spam) # spam fixture

    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime("%m-%d-%Y"),
        id: note.title.parameterize

    assert_redirected_to '/'
  end

  test "should get index" do
    get :index

    assert_response :success
    assert_not_nil :notes
  end

  test "should get raw note markup" do
    id = DrupalNode.where(type: 'note', status: 1).last.id

    get :raw, id: id

    assert_response :success
  end

  test "should show main image for node, returning blank image if it has none" do
    node = node(:one)

    get :image, id: node.id

    assert_response :redirect
    assert_redirected_to "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"
  end

  test "should get tools" do
    get :tools

    assert_response :redirect
    assert_redirected_to "/methods"
  end

  test "should get methods" do
  get :methods

  assert_response :success
  assert_not_nil :notes
  end

  test "should get places" do
    get :places

    assert_response :success
    assert_not_nil :notes
  end

  test "post note no login" do
    # kind of weird, to successfully log out, we seem to have to first log in to get the UserSession...
    user_session = UserSession.create(rusers(:bob))
    user_session.destroy
    title = "My new post about balloon mapping"

    post :create,
         id: rusers(:bob).id,
         title: title,
         body: "This is a fascinating post about a balloon mapping event.",
         tags: "balloon-mapping,event"
         #, main_image: "/images/testimage.jpg"

    assert_redirected_to('/login')
  end

  test "non-first-timer posts note" do
    UserSession.create(rusers(:jeff))
    title = "My new post about balloon mapping"
    assert !rusers(:jeff).first_time_poster
    assert User.where(role: 'moderator').count > 0

    assert_difference 'ActionMailer::Base.deliveries.size', User.where(role: 'moderator').count do

      post :create,
           title: title,
           body:  "This is a fascinating post about a balloon mapping event.",
           tags:  "balloon-mapping,event"
           #, main_image: "/images/testimage.jpg"

    end

    email = ActionMailer::Base.deliveries.last
    assert_equal "[PublicLab] " + title, email.subject
    assert_equal 1, DrupalNode.last.status
    assert_redirected_to "/notes/"+rusers(:jeff).username+"/"+Time.now.strftime("%m-%d-%Y")+"/"+title.parameterize
  end

  test "first-timer posts note" do
    UserSession.create(rusers(:lurker))
    title = "My first post to Public Lab"

    post :create,
         title: title,
         body: "This is a fascinating post about a balloon mapping event.",
         tags: "balloon-mapping,event"
         #, :main_image => "/images/testimage.jpg"

    assert_equal "Success! Thank you for contributing open research, and thanks for your patience while your post is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so.", flash[:notice]
    assert_nil flash[:warning] # no double notice
    assert_equal 4, DrupalNode.last.status
    assert_equal title, DrupalNode.last.title
    assert_redirected_to "/notes/"+rusers(:lurker).username+"/"+Time.now.strftime("%m-%d-%Y")+"/"+title.parameterize
  end

  test "first-timer moderated note (status=4) hidden to normal users on research note feed" do
    node = node(:first_timer_note)
    assert_equal 4, node.status

    get :index

    assert_select ".note-nid-#{node.id}", false
  end

  test "first-timer moderated note (status=4) hidden to normal users in full view" do
    node = node(:first_timer_note)
    assert_equal 4, node.status

    get :show,
        author: node.author.username,
        date: node.created_at.strftime("%m-%d-%Y"),
        id: node.title.parameterize

    assert_redirected_to "/"
  end

  test "first-timer moderated note (status=4) shown to author in full view with notice" do
    node = node(:first_timer_note)
    UserSession.create(node.author.user)
    assert_equal 4, node.status

    get :show,
        author: node.author.username,
        date: node.created_at.strftime("%m-%d-%Y"),
        id: node.title.parameterize

    assert_response :success
    assert_equal "Thank you for contributing open research, and thanks for your patience while your post is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so.", flash[:warning]
  end

  test "first-timer moderated note (status=4) shown to author in list view with notice" do
    node = node(:first_timer_note)
    UserSession.create(node.author.user)
    assert_equal 4, node.status

    get :index

    assert_response :success
    assert_select "div.note"
    assert_select "div.note-nid-#{node.nid} p.moderated", "Pending approval by community moderators. Please be patient!"
  end

  test "first-timer moderated note (status=4) shown to moderator with notice and approval prompt in full view" do
    UserSession.create(rusers(:moderator))
    node = node(:first_timer_note)
    assert_equal 4, node.status

    get :show,
        author: node.author.username,
        date: node.created_at.strftime("%m-%d-%Y"),
        id: node.title.parameterize

    assert_response :success
    assert_equal "First-time poster <a href='#{node.author.name}'>#{node.author.name}</a> submitted this #{time_ago_in_words(node.created_at)} ago and it has not yet been approved by a moderator. <a class='btn btn-default btn-sm' href='/moderate/publish/#{node.id}'>Approve</a> <a class='btn btn-default btn-sm' href='/moderate/spam/#{node.id}'>Spam</a>", flash[:warning]
  end

  test "first-timer moderated note (status=4) shown to moderator with notice and approval prompt in list view" do
    UserSession.create(rusers(:moderator))
    node = node(:first_timer_note)
    assert_equal 4, node.status

    get :index

    assert_response :success
    assert_select "div.note"
    assert_select "div.note-nid-#{node.nid} p.moderated", "Moderate first-time post: \n              Approve\n              Spam"
  end

  test "post_note_error_no_title" do
    UserSession.create(rusers(:bob))

    post :create,
         body: "This is a fascinating post about a balloon mapping event.",
         tags: "balloon-mapping,event"

    assert_template "editor/post"
    assert_select ".alert"
  end

  test "posting note successfully with no errors using xhr (rich editor)" do
    UserSession.create(rusers(:bob))

    xhr :post,
        :create,
        body: "This is a fascinating post about a balloon mapping event.",
        title: "A completely unique snowflake",
        tags: "balloon-mapping,event"

    assert_response :success
    assert_not_nil @response.body
    assert_equal '/notes/Bob/' + Time.now.strftime("%m-%d-%Y") + '/a-completely-unique-snowflake', @response.body
  end

  test "post_note_error_no_title_xhr" do
    UserSession.create(rusers(:bob))

    xhr :post,
        :create,
        body: "This is a fascinating post about a balloon mapping event.",
        tags: "balloon-mapping,event"

    assert_response :success
    assert_not_nil @response.body
    json = JSON.parse(@response.body)
    assert_equal ["can't be blank"], json['title']
    assert json['title'].length > 0
  end

  #def test_cannot_delete_post_if_not_yours

  #end

  test "should load iframe url in comments" do
    comment = Comment.new({
      nid: node(:one).nid,
      uid: rusers(:bob).id,
      thread: "01/"
    })
    comment.comment = '<iframe src="http://mapknitter.org/embed/sattelite-imagery" style="border:0;"></iframe>'
    comment.save
    node = node(:one).path.split("/")

    get :show, id: node[4], author: node[2], date: node[3]

    assert_tag :tag => 'iframe', attributes: {src: 'http://mapknitter.org/embed/sattelite-imagery'}
  end

  # test "should mark admins and moderators with a special icon" do
  #   node = node(:one)
  #   get :show,
  #       author: node.author.username,
  #       date: node.created_at.strftime("%m-%d-%Y"),
  #       id: node.title.parameterize
  #   assert_select "i[title='Admin']", 1
  #   assert_select "i[title='Moderator']", 1
  # end

  test "should display an icon for users with streak longer than 7 days" do
    node = node(:one)
    User.any_instance.stubs(:note_streak).returns([8,10])
    User.any_instance.stubs(:wiki_edit_streak).returns([9,15])
    User.any_instance.stubs(:comment_streak).returns([10,30])
    get :show,
        author: node.author.username,
        date: node.created_at.strftime("%m-%d-%Y"),
        id: node.title.parameterize
    assert_select ".fa-fire", 3
  end

  test "should redirect to questions show page after creating a new question" do
    user = UserSession.create(rusers(:bob))
    title = "How to use Spectrometer"
    post :create,
         title: title,
         body: "Spectrometer question",
         tags: "question:spectrometer",
         redirect: "question"

    assert_redirected_to "/questions/" + rusers(:bob).username + "/" + Time.now.strftime("%m-%d-%Y") + "/" + title.parameterize
    assert_equal "Success! Thank you for contributing with a question, and thanks for your patience while your question is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published.", flash[:notice]
  end

  test "non-first-timer posts a question" do
    UserSession.create(rusers(:jeff))
    title = "My first question to Public Lab"
    post :create,
         title: title,
         body: "Spectrometer question",
         tags: "question:spectrometer",
         redirect: "question"

    assert_redirected_to "/questions/" + rusers(:jeff).username + "/" + Time.now.strftime("%m-%d-%Y") + "/" + title.parameterize
    assert_equal flash[:notice], "Question published. In the meantime, if you have more to contribute, feel free to do so."
  end

  test "should display /post template when editing a note" do
    user = UserSession.create(rusers(:jeff))
    note = node(:blog)
    post :edit,
         id: note.nid

    assert_response :success
    assert_select "input#taginput[value=?]", note.tagnames.join(',')
  end

  test "should display /post template when editing a question" do
    user = UserSession.create(rusers(:jeff))
    note = node(:question)
    note.add_tag('nice', rusers(:jeff))
    post :edit,
         id: note.nid

    assert_response :success
    assert_select "input#taginput[value=?]", note.tagnames.join(',') + ',spectrometer' # for now, question subject is appended to end of form
  end

  test "should redirect to questions show page when editing an existing question" do
    user = UserSession.create(rusers(:jeff))
    note = node(:question)
    post :update,
         id: note.nid,
         title: note.title,
         body: "Spectrometer doubts",
         tags: "question:spectrometer",
         redirect: "question"

    assert_redirected_to note.path(:question) + "?_=" + Time.now.to_i.to_s
  end

  test "should update a former note that has become a question by tagging" do
    node = node(:blog)
    node.add_tag('question:foo', rusers(:bob))

    post :update,
         id: node.nid,
         title: node.title + ' amended'

    assert_response :redirect
  end

  test "returning json errors on xhr note update" do
    user = UserSession.create(rusers(:jeff))

    xhr :post,
        :update,
        id: node(:blog).id,
        title: ""

    assert_response :success
    assert_not_nil @response.body
    json = JSON.parse(@response.body)
    assert json['title'].length > 0
  end

  test "should redirect to question path if node is a question when visiting shortlink" do
    node = node(:question)
    get :shortlink, id: node.id
    assert_redirected_to node.path(:question)
  end

  test "should redirect to question path if node is a question when visiting show path" do
    note = node(:question)

    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime("%m-%d-%Y"),
        id: note.title.parameterize
    assert_redirected_to note.path(:question)
  end

  test "should list only research notes with status 1 in index" do
    get :index
    notes = assigns(:notes)
    expected = [node(:one)]
    questions = [node(:question)]
    assert (notes & expected).present?
    assert !(notes & questions).present?
  end

  test "should list research notes with status 1 & 4 in index if admin is logged in" do
    UserSession.create(rusers(:admin))
    get :index
    notes = assigns(:notes)
    expected = [node(:one), node(:first_timer_note)]
    questions = [node(:question)]
    assert (notes & expected).present?
    assert !(notes & questions).present?
  end

  test "should list only research notes with status 1 in popular" do
    UserSession.create(rusers(:admin))
    get :popular
    notes = assigns(:notes)
    expected = [node(:one)]
    questions = [node(:question)]
    assert (notes & expected).present?
    assert !(notes & questions).present?
  end

  test "should list only research notes with status 1 in liked" do
    UserSession.create(rusers(:admin))
    get :liked
    notes = assigns(:notes)
    expected = [node(:one)]
    questions = [node(:question)]
    assert (notes & expected).present?
    assert !(notes & questions).present?
  end

  test "should choose I18n for notes controller" do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, :locale => lang.to_s

      @controller = old_controller

      UserSession.create(rusers(:jeff))
      title = "Some post to Public Lab"

      post :create,
           title: title+lang.to_s,
           body: "Some text.",
           tags: "event"

      assert_equal I18n.t('notes_controller.research_note_published'), flash[:notice]
    end
  end

end
