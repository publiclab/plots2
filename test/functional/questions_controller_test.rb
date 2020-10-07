require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:questions)
    assert assigns(:questions).first.has_power_tag('question')
  end

  test 'should get show' do
    note = nodes(:question)

    get :show, params: { author: note.author.name, date: Time.at(note.created).strftime('%m-%d-%Y'), id: note.title.parameterize }

    assert_response :success
  end

  test 'show question by id' do
    note = nodes(:question)

    get :show, params: { id: note.id }

    assert_response :success
  end

  test 'question comment markdown and autolinking works' do
    node = nodes(:question)
    assert node.comments.length.positive?
    comment = node.comments.last
    comment.comment = 'Test **markdown** and http://links.com'
    comment.save!

    get :show, params: { id: node.id }

    assert_select 'strong', 'markdown'
    assert_select 'a', 'http://links.com'
    assert_response :success
  end

  test 'should redirect notes other than question to note path' do
    note = nodes(:one)

    get :show, params: { author: note.author.name, date: Time.at(note.created).strftime('%m-%d-%Y'), id: note.title.parameterize }

    assert_redirected_to note.path
  end

  test 'redirect question to short url' do
    note = nodes(:question)
    get :shortlink, params: { id: note.id }
    assert_redirected_to note.path(:question)
  end

  test 'should get popular' do
    get :popular
    assert_response :success
  end

  test 'should get liked' do
    get :liked
    assert_response :success
  end

  test 'should not show answer accept button to users if not logged in' do
    note = nodes(:question)
    answer = answers(:one)

    get :show, params: { author: note.author.name, date: Time.at(note.created).strftime('%m-%d-%Y'), id: note.title.parameterize  }

    assert_response :success
    assert_select '#answer-' + answer.id.to_s + '-accept', 0
  end

  test 'should not show accept answer button to user who is not the author of the question' do
    UserSession.create(users(:bob))
    note = nodes(:question)
    answer = answers(:one)

    get :show, params: { author: note.author.name, date: Time.at(note.created).strftime('%m-%d-%Y'), id: note.title.parameterize }

    assert_response :success
    assert_select '#answer-' + answer.id.to_s + '-accept', 0
  end

  test 'should get answered' do
    get :recently_commented
    assert_response :success
    assert_equal assigns(:title), 'Recently Commented'
    assert_not_nil assigns(:questions)
    assert_template :index
  end

  test 'should get unanswered' do
    get :unanswered
    assert_response :success
    assert_equal assigns(:title), 'Unanswered questions'
    assert_not_nil assigns(:questions)
    assert_equal assigns(:questions).first.answers.length, 0
    assert_template :index
  end

  test 'should list questions with status 1 in index' do
    get :index
    questions = assigns(:questions)
    expected = [nodes(:question), nodes(:question2)]
    notes = [nodes(:one), nodes(:first_timer_question)]
    assert (questions & expected).present?
    assert !(questions & notes).present?
  end

  test 'should list questions with status 1 & 4 in index to admin' do
    UserSession.create(users(:admin))
    get :index
    questions = assigns(:questions)
    expected = [nodes(:question), nodes(:question2), nodes(:first_timer_question)]
    notes = [nodes(:one)]
    assert (questions & expected).present?
    assert !(questions & notes).present?
  end

  test 'should list questions with status 1 in popular' do
    UserSession.create(users(:admin))
    get :popular
    questions = assigns(:questions)
    expected = [nodes(:question), nodes(:question2)]
    notes = [nodes(:one)]
    assert (questions & expected).present?
    assert !(questions & notes).present?
  end

  test 'should list questions with status 1 in liked' do
    UserSession.create(users(:admin))
    get :liked
    questions = assigns(:questions)
    expected = [nodes(:question), nodes(:question2)]
    notes = [nodes(:one)]
    assert (questions & expected).present?
    assert !(questions & notes).present?
  end

  test 'should list only answered questions in answered' do
    get :recently_commented
    questions = assigns(:questions)
    expected = [nodes(:question)]
    assert (questions & expected).present?
    assert !(questions & [nodes(:question2)]).present?
  end

  test '/questions/new form loads' do
    UserSession.create(users(:bob))
    get :new
    assert_response :success
  end
end
