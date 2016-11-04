require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  
  def setup
    activate_authlogic
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:questions)
    assert assigns(:questions).first.has_power_tag('question')
  end

  test "should get show" do
    note = node(:question)
    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime("%m-%d-%Y"),
        id: note.title.parameterize

    assert_response :success
  end

  test "show note by id" do
    note = node(:question)
    get :show, id: note.id
    assert_response :success
  end

  test "should redirect notes other than question to note path" do
    note = node(:one)
    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime("%m-%d-%Y"),
        id: note.title.parameterize
    assert_redirected_to note.path
  end

  test "redirect question to short url" do
    note = node(:question)
    get :shortlink, id: note.id
    assert_redirected_to note.path(:question)
  end

  test "should get popular" do
    get :popular
    assert_response :success
  end

  test "should get liked" do
    get :liked
    assert_response :success
  end

  test "should show accepted label for accepted answers" do
    note = node(:question)
    answer = answers(:two)
    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime("%m-%d-%Y"),
        id: note.title.parameterize

    assert_response :success
    assert_select '#answer-' + answer.id.to_s + '-accept', 1
  end

  test "should not show answer accept button to users if not logged in" do
    note = node(:question)
    answer = answers(:one)
    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime("%m-%d-%Y"),
        id: note.title.parameterize

    assert_response :success
    assert_select '#answer-' + answer.id.to_s + '-accept', 0
  end

  test "should show accept answer button to author of the question" do
    UserSession.create(rusers(:jeff))
    note = node(:question)
    answer = answers(:one)
    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime("%m-%d-%Y"),
        id: note.title.parameterize

    assert_response :success
    assert_select '#answer-' + answer.id.to_s + '-accept', 1
  end

  test "should not show accept answer button to user who is not the author of the question" do
    UserSession.create(rusers(:bob))
    note = node(:question)
    answer = answers(:one)
    get :show,
        author: note.author.name,
        date: Time.at(note.created).strftime("%m-%d-%Y"),
        id: note.title.parameterize

    assert_response :success
    assert_select '#answer-' + answer.id.to_s + '-accept', 0
  end

  test "should get answered" do
    get :answered
    assert_response :success
    assert_equal assigns(:title), "Recently answered"
    assert_not_nil assigns(:questions)
    assert_template :index
  end

  test "should list questions with status 1 in index" do
    get :index
    questions = assigns(:questions)
    expected = [node(:question), node(:question2)]
    notes = [node(:one), node(:first_timer_question)]
    assert (questions & expected).present?
    assert !(questions & notes).present?
  end

  test "should list questions with status 1 & 4 in index to admin" do
    UserSession.create(rusers(:admin))
    get :index
    questions = assigns(:questions)
    expected = [node(:question), node(:question2), node(:first_timer_question)]
    notes = [node(:one)]
    assert (questions & expected).present?
    assert !(questions & notes).present?
  end

  test "should list questions with status 1 in popular" do
    UserSession.create(rusers(:admin))
    get :popular
    questions = assigns(:questions)
    expected = [node(:question), node(:question2)]
    notes = [node(:one)]
    assert (questions & expected).present?
    assert !(questions & notes).present?
  end

  test "should list questions with status 1 in liked" do
    UserSession.create(rusers(:admin))
    get :liked
    questions = assigns(:questions)
    expected = [node(:question), node(:question2)]
    notes = [node(:one)]
    assert (questions & expected).present?
    assert !(questions & notes).present?
  end

  test "should list only answered questions in answered" do
    UserSession.create(rusers(:admin))
    get :answered
    questions = assigns(:questions)
    expected = [node(:question)]
    assert (questions & expected).present?
    assert !(questions & [node(:question2)]).present?
  end
  
  test "/questions/new form loads" do
    get :new
    assert_response :success
  end
end
