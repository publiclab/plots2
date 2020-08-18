require 'test_helper'
class NotesControllerTest < ActionController::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  def setup
    Timecop.freeze # account for timestamp change
    activate_authlogic
  end

  def teardown
    Timecop.return
  end

  test 'redirect note short url' do
    note = Node.where(type: 'note', status: 1).first

    get :shortlink, params: { id: note.id }

    assert_redirected_to note.path
  end

  test 'show note by id' do
    note = Node.where(type: 'note', status: 1).first
    assert_not_nil note.id

    get :show, params: { id: note.id }

    assert_response :success
  end

  test 'show note' do
    note = nodes(:blog)
    note.add_tag('activity:nonexistent', note.author) # testing responses display
    assert_equal 'nonexistent', note.power_tag('activity')

    get :show,
        params: {
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize
        }

    assert_response :success
    assert_select '#other-activities', false
  end

  test 'print note template' do
    note = nodes(:blog)

    get :print,
        params: {
        id: note.nid
        }

    assert_template 'print'
    assert_response :success
  end

  test 'comment markdown and autolinking works' do
    node = Node.where(type: 'note', status: 1).first
    assert node.comments.length > 0
    comment = node.comments.last(2).first
    comment.comment = 'Test **markdown** and http://links.com'
    comment.save!

    get :show, params: { id: node.id }

    assert_select 'strong', 'markdown'
    assert_select 'a', 'http://links.com'

    assert_response :success
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
          params: {
          author: note.author.name,
          date: Time.at(note.created).strftime('%m-%d-%Y'),
          id: note.title.parameterize
          }
    end

    assert_equal '0.0.0.0', Impression.last.ip_address
    Impression.last.update_attribute('ip_address', '0.0.0.1')

    assert_difference 'note.reload.views', 1 do
      get :show,
          params: {
          author: note.author.name,
          date: Time.at(note.created).strftime('%m-%d-%Y'),
          id: note.title.parameterize
          }
    end

    assert_equal 2, note.reload.views

    # same IP won't add to views twice
    assert_difference 'note.reload.views', 0 do
      get :show,
          params: {
          author: note.author.name,
          date: Time.at(note.created).strftime('%m-%d-%Y'),
          id: note.title.parameterize
          }
    end
  end

  test 'redirect normal user to tagged blog page' do
    note = nodes(:one)
    blog = nodes(:blog)
    note.add_tag("redirect:#{blog.nid}", users(:jeff))
    assert_equal blog.nid.to_s, note.power_tag('redirect')

    get :show,
        params: {
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize
        }

    assert_redirected_to blog.path
  end

  test 'admins and moderators view redirect-tagged notes with flash warning' do
    note = nodes(:one)
    blog = nodes(:blog)
    flash_msg = "Only moderators and admins see this page, as it is redirected to #{blog.title}. To remove the redirect, delete the tag beginning with 'redirect:'"

    note.add_tag("redirect:#{blog.nid}", users(:jeff))
    assert_equal blog.nid.to_s, note.power_tag('redirect')
    UserSession.find.destroy if UserSession.find
    UserSession.create(users(:jeff))

    get :show,
        params: {
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize
        }

    assert_response :success
    assert_equal flash_msg, flash[:warning]
    UserSession.find.destroy
  end

  test 'show note with Browse other activities link' do
    note = Node.where(type: 'note', status: 1).first
    note.add_tag('activity:spectrometer', note.author) # testing responses display
    assert !Tag.where(name: 'activities:' + note.power_tag('activity')).empty?

    get :show,
        params: {
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize
        }

    assert_response :success
    assert_select '#other-activities'
    assert_select "a#other-activities[href = '/wiki/spectrometer']", 1
  end

  test 'return 404 when node is not found' do
    note = nodes(:one)

    get :show, params: {
      author: note.author.name,
      date: Time.at(note.created).strftime('%m-%d-%Y'),
      id: "doesn't_exist"
    }

    assert_response :not_found
  end

  test "don't show note by spam author" do
    note = nodes(:spam) # spam fixture

    get :show,
        params: {
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize
        }

    assert_redirected_to '/'
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil :notes
  end

  test 'should get raw note markup' do
    id = Node.where(type: 'note', status: 1).last.id

    get :raw, params: { id: id }

    assert_response :success
  end

  test 'should show main image for node, returning blank image if it has none' do
    node = nodes(:one)

    get :image, params: { id: node.id }

    assert_response :redirect
    assert_redirected_to '/logo.png'
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
         params: { id: users(:bob).id,
         title: title,
         body: 'This is a fascinating post about a balloon mapping event.',
         tags: 'balloon-mapping,event'
         }
    # , main_image: "/images/testimage.jpg"

    assert_redirected_to('/login?return_to=/notes/create')
  end

  test 'non-first-timer posts note' do
    UserSession.create(users(:jeff))
    title = 'My new post about balloon mapping'
    assert !users(:jeff).first_time_poster
    assert User.where(role: 'moderator').count > 0
    perform_enqueued_jobs do
      assert_difference 'ActionMailer::Base.deliveries.size', User.where(role: 'moderator').count do
        post :create,
             params: { title: title,
             body:  'This is a fascinating post about a balloon mapping event.',
             tags:  'balloon-mapping,event'
             }
        # , main_image: "/images/testimage.jpg"
      end

      email = ActionMailer::Base.deliveries.last
      assert_equal '[PublicLab] ' + title + ' (#' + Node.last.id.to_s + ') ', email.subject
      assert_equal 1, Node.last.status
      assert_redirected_to '/notes/' + users(:jeff).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
    end
  end

  test 'first-timer posts note' do
    UserSession.create(users(:lurker))
    title = 'My first post to Public Lab'

    post :create,
         params: { title: title,
         body: 'This is a fascinating post about a balloon mapping event.',
         tags: 'balloon-mapping,event'
         }
    # , :main_image => "/images/testimage.jpg"

    assert_equal "Success! Thank you for contributing open research, and thanks for your patience while your post is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so.", flash[:notice]
    assert_nil flash[:warning] # no double notice
    assert_equal 4, Node.last.status
    assert_equal title, Node.last.title
    assert_redirected_to '/notes/' + users(:lurker).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
  end

  test 'Email to the mentioned users in note creation' do
    UserSession.create(users(:naman))
    title = 'Note with Mentioned users in body'
    post :create,
         params: { title: title,
                   body: '@naman18996 and @jeffrey are the mentioned users',
                   tags: 'balloon-mapping,event'
         }
    node = Node.last
    emails = []
    ActionMailer::Base.deliveries.each do |m|
      if m.subject == "(##{node.id}) You were mentioned in a note"
        emails = emails + m.to
      end
    end
    assert_equal 2, emails.count
    assert_equal ["naman18996@yahoo.com", "jeff@publiclab.org"].to_set, emails.to_set
  end

  test 'first-timer moderated note (status=4) hidden to normal users on research note feed' do
    node = nodes(:first_timer_note)
    assert_equal 4, node.status

    get :index

    selector = css_select ".note-nid-#{node.id}"
    assert_equal selector.size, 0
  end

  test 'first-timer moderated note (status=4) hidden to normal users in full view' do
    node = nodes(:first_timer_note)
    assert_equal 4, node.status

    get :show,
        params: {
        author: node.author.username,
        date: node.created_at.strftime('%m-%d-%Y'),
        id: node.title.parameterize
        }

    assert_redirected_to '/'
  end

  test 'first-timer moderated note (status=4) shown to author in full view with notice' do
    node = nodes(:first_timer_note)
    UserSession.create(node.author)
    assert_equal 4, node.status

    get :show,
        params: {
        author: node.author.username,
        date: node.created_at.strftime('%m-%d-%Y'),
        id: node.title.parameterize
        }

    assert_response :success
    assert_equal "Thank you for contributing open research, and thanks for your patience while your post is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published. In the meantime, if you have more to contribute, feel free to do so.", flash[:warning]
  end

  test 'first-timer moderated note (status=4) shown to author in list view with notice' do
    node = nodes(:first_timer_note)
    UserSession.create(node.author)
    assert_equal 4, node.status

    get :index

    assert_response :success
    selector = css_select 'div.note'
    assert_equal 27, selector.size
    assert_select "div p", 'Pending approval by community moderators. Please be patient!'
  end

  test 'first-timer moderated note (status=4) shown to moderator with notice and approval prompt in full view' do
    UserSession.create(users(:moderator))
    node = nodes(:first_timer_note)
    assert_equal 4, node.status

    get :show,
        params: {
        author: node.author.username,
        date: node.created_at.strftime('%m-%d-%Y'),
        id: node.title.parameterize
        }

    assert_response :success
    assert_equal "First-time poster <a href='/profile/#{node.author.name}'>#{node.author.name}</a> submitted this #{time_ago_in_words(node.created_at)} ago and it has not yet been approved by a moderator. <a class='btn btn-default btn-sm' href='/moderate/publish/#{node.id}'>Approve</a> <a class='btn btn-default btn-sm' href='/moderate/spam/#{node.id}'>Spam</a>", flash[:warning]
  end

  test 'first-timer moderated note (status=4) shown to moderator with notice and approval prompt in list view' do
    UserSession.create(users(:moderator))
    node = nodes(:first_timer_note)
    assert_equal 4, node.status

    get :index

    assert_response :success
    selector = css_select 'div.note'
    assert_equal 27, selector.size
    assert_select 'a[data-test="spam"]','Spam'
  end

  test 'post_note_error_no_title' do
    UserSession.create(users(:bob))

    post :create,
         params: {
         body: 'This is a fascinating post about a balloon mapping event.',
         tags: 'balloon-mapping,event'
         }

    assert_template 'editor/post'
    selector = css_select '.alert'
    assert_equal selector.size, 2
  end

  test 'posting note successfully with no errors using xhr (rich editor)' do
    UserSession.create(users(:bob))

    post :create,
        params: {
        body: 'This is a fascinating post about a balloon mapping event.',
        title: 'A completely unique snowflake',
        tags: 'balloon-mapping,event'
        }, xhr: true

    assert_response :success
    assert_not_nil @response.body
    assert_equal '/notes/Bob/' + Time.now.strftime('%m-%d-%Y') + '/a-completely-unique-snowflake', @response.body
  end

  test 'post_note_error_no_title_xhr' do
    UserSession.create(users(:bob))

    post :create,
        params: {
        body: 'This is a fascinating post about a balloon mapping event.',
        tags: 'balloon-mapping,event'
        }, xhr: true

    assert_response :success
    assert_not_nil @response.body
    json = JSON.parse(@response.body)
    assert_equal ["can't be blank", "is too short (minimum is 3 characters)"], json['title']
    assert !json['title'].empty?
  end

  test 'posting note with an error using xhr (rich editor) returns a JSON error' do
    UserSession.create(users(:bob))

    post :create,
        params: {
        body: 'This is a fascinating post about a balloon mapping event.',
        title: '',
        tags: 'balloon-mapping,event'
        }, xhr: true

    assert_response :success
    assert_not_nil @response.body
  end

  test 'returning json errors on xhr note update' do
    user = UserSession.create(users(:jeff))

    post :update,
        params: {
        id: nodes(:blog).id,
        title: ''
        }, xhr: true

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

    get :show, params: { id: node[4], author: node[2], date: node[3] }

    assert_select 'iframe[src=?]', 'http://mapknitter.org/embed/sattelite-imagery'
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
    User.any_instance.stubs(:wiki_edit_streak).returns([9, 17])
    User.any_instance.stubs(:comment_streak).returns([10, 30])
    get :show,
        params: {
        author: node.author.username,
        date: node.created_at.strftime('%m-%d-%Y'),
        id: node.title.parameterize
        }
    selector = css_select '.fa-fire'
    assert_equal 4, selector.size
  end

  test 'should redirect to questions show page after creating a new question' do
    title = 'How to use Spectrometer'
    perform_enqueued_jobs do
      assert_emails 1 do
        user = UserSession.create(users(:bob))
        post :create,
             params: {
             title: title,
             body: 'Spectrometer question',
             tags: 'question:spectrometer',
             redirect: 'question'
             }
        node = nodes(:blog)
      end
    end

    assert_redirected_to '/questions/' + users(:bob).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
    assert_equal "Success! Thank you for contributing with a question, and thanks for your patience while your question is approved by <a href='/wiki/moderation'>community moderators</a> and we'll email you when it is published.", flash[:notice]
  end

  test 'non-first-timer posts a question' do
    UserSession.create(users(:jeff))
    title = 'My first question to Public Lab'
    post :create,
         params: {
         title: title,
         body: 'Spectrometer question',
         tags: 'question:spectrometer',
         redirect: 'question'
         }

    assert_redirected_to '/questions/' + users(:jeff).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
    assert_equal flash[:notice], 'Question published. In the meantime, if you have more to contribute, feel free to do so.'
  end

  test 'should display /post template when editing a note in legacy mode' do
    user = UserSession.create(users(:jeff))
    note = nodes(:blog)
    get :edit,
         params: {
         id: note.nid,
         legacy: true
         }
    assert_response :success
    assert_select 'input#taginput[value=?]', note.tagnames.join(',')
  end

  test 'should display /post template when editing a question in legacy mode' do
    user = UserSession.create(users(:jeff))
    note = nodes(:question)
    note.add_tag('nice', users(:jeff))
    get :edit,
         params: {
         id: note.nid,
         legacy: true
         }
    assert_response :success
    assert_select 'input#taginput[value=?]', note.tagnames.join(',') + ',spectrometer' # for now, question subject is appended to end of form
  end

  test 'should display /post template when editing a note' do
    user = UserSession.create(users(:jeff))
    note = nodes(:blog)
    get :edit,
         params: {
         id: note.nid
         }
    assert_response :success
    selector = css_select "input.form-control.input-lg[value='#{note.tagnames.join(',')}']"
    assert_equal selector.size, 1
  end

  test 'should display /post template when editing a question' do
    user = UserSession.create(users(:jeff))
    note = nodes(:question)
    note.add_tag('nice', users(:jeff))
    get :edit,
         params: {
         id: note.nid
         }
    assert_response :success
    selector = css_select "input.form-control.input-lg[value='#{note.tagnames.join(',')}']"
    assert_equal selector.size, 1
  end

  test 'should redirect to questions show page when editing an existing question' do
    user = UserSession.create(users(:jeff))
    note = nodes(:question)
    post :update, params: { id: note.nid, title: note.title, body: 'Spectrometer doubts', tags: 'question:spectrometer', redirect: 'question' }

    assert_redirected_to note.path(:question) + '?_=' + Time.now.to_i.to_s
  end


  test 'should render a text/plain when the note is edited through xhr' do
    user = UserSession.create(users(:jeff))
    note = nodes(:one)
    post :update, params: { id: note.nid, title: note.title, body: 'Canon A1200 IR Conversion is working' }, xhr: true
    assert_equal I18n.t('notes_controller.edits_saved'), flash[:notice]
    assert_equal "text/plain", @response.content_type
    assert_equal "#{note.path(false).to_s}?_=#{Time.now.to_i}", @response.body
  end

  test 'should update a former note that has become a question by tagging' do
    node = nodes(:blog)
    node.add_tag('question:foo', users(:bob))

    post :update,
         params: {
         id: node.nid,
         title: node.title + ' amended'
         }

    assert_response :redirect
  end

  test 'should redirect to question path if node is a question when visiting shortlink' do
    node = nodes(:question)
    get :shortlink, params: { id: node.id}
    assert_redirected_to node.path(:question)
  end

  test 'should redirect to question path if node is a question when visiting show path' do
    note = nodes(:question)

    get :show,
        params: {
        author: note.author.name,
        date: Time.at(note.created).strftime('%m-%d-%Y'),
        id: note.title.parameterize
        }
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

  test 'should list only research notes with status 1 in recent' do
    get :recent
    notes = assigns(:notes)
    expected = [nodes(:one)]
    questions = [nodes(:question)]
    assert (notes & expected).present?
    assert (notes & questions).present?
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

    test 'first note in /liked endpoint should be highest liked' do
    get :liked
    notes = assigns(:notes)
    # gets highest liked note's number of likes
    expected = Node.research_notes.where(status: 1).maximum("cached_likes")
    # gets first note of /notes/liked endpoint
    actual = notes.first
    # both should be equal
    assert expected == actual.cached_likes
  end
  test 'first note in /recent endpoint should be most recent' do
    get :recent
    notes = assigns(:notes)
    expected = Node.where(type: 'note', status: 1, created: Time.now.to_i - 1.weeks.to_i..Time.now.to_i)
                   .maximum("created")
    actual = notes.first
    assert expected == actual.created
  end

  test 'first three posts in /liked should be sorted by likes' do
    get :liked
    # gets first notes
    notes = assigns(:notes)[0...3]
     # sort_by is from lowest to highest so it needs to be reversed
    assert notes.sort_by { |note| note.cached_likes }.reverse ==  notes
  end

  test 'should choose I18n for notes controller' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      get :change_locale, params: { locale: lang.to_s }

      @controller = old_controller

      UserSession.create(users(:jeff))
      title = 'Some post to Public Lab'

      post :create,
           params: {
           title: title + lang.to_s,
           body: 'Some text.',
           tags: 'event'
           }

      assert_equal I18n.t('notes_controller.research_note_published'), flash[:notice]
    end
  end

  test "should delete wiki if other author have not contributed" do
    node = nodes(:one)
    length=node.authors.uniq.length
    user = UserSession.create(users(:jeff))
    assert_equal 1,length

    assert_difference 'Node.count', -1 do
      post :delete, params: {id: node.nid}
    end

    assert_redirected_to '/dashboard' + '?_=' + Time.now.to_i.to_s
  end

  test "should not delete wiki if other author have contributed" do
    node = nodes(:about)
    length=node.authors.uniq.length
    assert_not_equal 1,length
    user = UserSession.create(users(:jeff))

    assert_no_difference 'Node.count' do
      get :delete, params: { id: node.nid }
    end

    assert_redirected_to '/dashboard' + '?_=' + Time.now.to_i.to_s
  end

  #should change title
  test 'title change feature in comments when author is logged in' do
    UserSession.create(users(:jeff))
    node = nodes(:one)
    post :update_title, params: { id: '1',title: 'changed title' }
    assert_redirected_to node.path+"#comments"
    assert_equal node.reload.title, 'changed title'
  end

  # should not change title
  test 'title change feature in comments when author is not logged in' do
    node = nodes(:one)
    post :update_title, params: { id: '1',title: 'changed title' }
    assert_redirected_to node.path+"#comments"
    assert_equal I18n.t('notes_controller.author_can_edit_note'), flash[:error]
    assert_equal node.reload.title, node.title
  end

  def test_get_rss_feed
    get :rss, :format => "rss"
    assert_response :success
    assert_equal 'application/xml', @response.content_type
  end

  test 'draft should not be shown when no user' do
    node = nodes(:draft)
    get :show, params: { id: '21',title: 'Draft note' }
    assert_response :missing
  end

  test 'draft should not be shown when user is not author' do
    node = nodes(:draft)
    UserSession.create(users(:bob))
    get :show, params: { id: '21',title: 'Draft note' }
    assert_response :missing
  end

  test 'question deletion should delete all its answers' do
    UserSession.create(users(:moderator))
    node = nodes(:question)
    node.save
    answer1 = answers(:one)
    answer1.save
    answer2 = answers(:two)
    answer2.save
    n_count = Node.count

    post :delete, params: { id: node.id }, xhr: true

    assert_response :success
    assert_equal Node.count, n_count - 1
    assert_equal Answer.count, 0
  end

  test 'moderator can publish the draft' do
    UserSession.create(users(:moderator))
    node = nodes(:draft)
    assert_equal 3, node.status
    ActionMailer::Base.deliveries.clear

    get :publish_draft, params: { id: node.id }

    assert_response :redirect
    assert_equal "Thanks for your contribution. Research note published! Now, it's visible publicly.", flash[:notice]
    node = assigns(:node)
    assert_equal 1, node.status
    assert_equal 1, node.author.status
    assert_redirected_to '/notes/' + users(:jeff).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + node.title.parameterize

    email = ActionMailer::Base.deliveries.last
    assert_equal '[PublicLab] ' + node.title + " (##{node.id}) ", email.subject
  end

   test 'draft author can publish the draft' do
     UserSession.create(users(:jeff))
     node = nodes(:draft)
     old_created = node['created']
     old_changed = node['changed']
     assert_equal 3, node.status
     ActionMailer::Base.deliveries.clear

     Timecop.freeze(Date.today + 1) do
        get :publish_draft, params: { id: node.id }

        assert_response :redirect

        assert_equal "Thanks for your contribution. Research note published! Now, it's visible publicly.", flash[:notice]
        node = assigns(:node)
        assert_equal 1, node.status
        assert_not_equal old_changed, node['changed'] # these should have been forward dated!
        assert_not_equal old_created, node['created']
        assert_equal 1, node.author.status
        assert_redirected_to '/notes/' + users(:jeff).username + '/' + (Time.now).strftime('%m-%d-%Y') + '/' + node.title.parameterize

        email = ActionMailer::Base.deliveries.last
        assert_equal '[PublicLab] ' + node.title + " (##{node.id}) ", email.subject
     end
   end

   test 'co-author can publish the draft' do
     UserSession.create(users(:test_user))
     node = nodes(:draft)
     assert_equal 3, node.status
     ActionMailer::Base.deliveries.clear

     get :publish_draft, params: { id: node.id }

     assert_response :redirect
     assert_equal "Thanks for your contribution. Research note published! Now, it's visible publicly.", flash[:notice]
     node = assigns(:node)
     assert_equal 1, node.status
     assert_equal 1, node.author.status
     assert_redirected_to '/notes/' + users(:jeff).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + node.title.parameterize

     email = ActionMailer::Base.deliveries.last
     assert_equal '[PublicLab] ' + node.title + " (##{node.id}) ", email.subject
   end

   test 'Normal user should not be allowed to publish the draft' do
     UserSession.create(users(:bob))
     node = nodes(:draft)
     assert_equal 3, node.status
     ActionMailer::Base.deliveries.clear

     get :publish_draft, params: { id: node.id }

     assert_response :redirect
     assert_equal "You are not author or moderator so you can't publish a draft!", flash[:warning]
     node = assigns(:node)
     assert_equal 3, node.status
     assert_equal 1, node.author.status
     assert_redirected_to '/'
     assert_equal ActionMailer::Base.deliveries.size, 0
   end

   test 'User should be logged in to publish draft' do
     node = nodes(:draft)
     assert_equal 3, node.status
     ActionMailer::Base.deliveries.clear

     get :publish_draft, params: { id: node.id }

     assert_response :redirect
     assert_equal "You must be logged in to access this page", flash[:warning]
     assert_equal 3, node.status
     assert_equal 1, node.author.status
     assert_redirected_to '/login?return_to=/notes/publish_draft/21'
     assert_equal ActionMailer::Base.deliveries.size, 0
   end

   test 'post draft no login' do
     user_session = UserSession.create(users(:bob))
     user_session.destroy
     title = 'My new post about balloon mapping'

     post :create,
         params: {
          id: users(:bob).id,
          title: title,
          body: 'This is a fascinating post about a balloon mapping event.',
          tags: 'balloon-mapping,event',
          draft: "true"
         }

     assert_redirected_to('/login?return_to=/notes/create')
   end

   test 'non-first-timer posts draft' do
     UserSession.create(users(:jeff))
     title = 'My new post about balloon mapping'
     assert !users(:jeff).first_time_poster

       post :create,
           params: {
            title: title,
            body:  'This is a fascinating post about a balloon mapping event.',
            tags:  'balloon-mapping,event',
            draft: "true"
           }

     assert_equal 3, Node.last.status
     assert_equal I18n.t('notes_controller.saved_as_draft'), flash[:notice]
     assert_redirected_to '/notes/' + users(:jeff).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
   end

   test 'first-timer posts draft' do
     UserSession.create(users(:lurker))
     title = 'My first post to Public Lab'

     post :create,
         params: {
          title: title,
          body: 'This is a fascinating post about a balloon mapping event.',
          tags: 'balloon-mapping,event',
          draft: "true"
         }

     assert_equal "First-time users are not eligible to create a draft.", flash[:notice]
     assert_redirected_to '/'
   end

   test 'draft note (status=3) shown to author in full view with notice' do
     node = nodes(:draft)
     UserSession.create(node.author)
     assert_equal 3, node.status

     get :show,
        params: {
         author: node.author.username,
         date: node.created_at.strftime('%m-%d-%Y'),
         id: node.title.parameterize
        }

     assert_response :success
     assert_equal "This is a draft note. Once you're ready, click <a class='btn btn-success btn-xs' href='/notes/publish_draft/#{node.id}'>Publish Draft</a> to make it public. You can share it with collaborators using this private link <a href='#{node.draft_url(request.base_url)}'>#{node.draft_url(request.base_url)}</a>", flash[:warning]
   end

   test 'draft note (status=3) shown to moderator in full view with notice' do
     UserSession.create(users(:moderator))
     node = nodes(:draft)
     assert_equal 3, node.status

     get :show,
        params: {
         author: node.author.username,
         date: node.created_at.strftime('%m-%d-%Y'),
         id: node.title.parameterize
        }

     assert_response :success
     assert_equal "This is a draft note. Once you're ready, click <a class='btn btn-success btn-xs' href='/notes/publish_draft/#{node.id}'>Publish Draft</a> to make it public. You can share it with collaborators using this private link <a href='#{node.draft_url(request.base_url)}'>#{node.draft_url(request.base_url)}</a>", flash[:warning]
   end

   test 'draft note (status=3) shown to co-author in full view with notice' do
     UserSession.create(users(:test_user))
     node = nodes(:draft)
     assert_equal 3, node.status

     get :show,
        params: {
         author: node.author.username,
         date: node.created_at.strftime('%m-%d-%Y'),
         id: node.title.parameterize
        }

     assert_response :success
     assert_equal "This is a draft note. Once you're ready, click <a class='btn btn-success btn-xs' href='/notes/publish_draft/#{node.id}'>Publish Draft</a> to make it public. You can share it with collaborators using this private link <a href='#{node.draft_url(request.base_url)}'>#{node.draft_url(request.base_url)}</a>", flash[:warning]
   end

   test 'draft note (status=3) shown to user with secret link' do
     node = nodes(:draft)
     assert_equal 3, node.status
     @token = node.slug.split('token:').last

     get :show,
         params: {
             id: node.nid,
             token: @token
         }
     assert_response :success
   end

   test 'no notification email if user posts draft' do
     UserSession.create(users(:jeff))
     title = 'My new post about balloon mapping'
     assert !users(:jeff).first_time_poster

     assert_difference 'ActionMailer::Base.deliveries.size', 0 do
     post :create,
          params: {
              title: title,
              body:  'This is a fascinating post about a balloon mapping event.',
              tags:  'balloon-mapping,event',
              draft: "true"
          }
      end
     assert_equal 3, Node.last.status
     assert_equal I18n.t('notes_controller.saved_as_draft'), flash[:notice]
     assert_redirected_to '/notes/' + users(:jeff).username + '/' + Time.now.strftime('%m-%d-%Y') + '/' + title.parameterize
   end
end
