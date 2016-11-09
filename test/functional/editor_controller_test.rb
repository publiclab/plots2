require 'test_helper'

class EditorControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test "should not get post form if not logged in" do
    get :post
    assert_redirected_to '/login'
  end

  test "should get post form" do
    UserSession.create(rusers(:bob))
    get :post,
        tags: 'one,two'
    assert_response :success
    assert_select "h3", "Share your work"
    assert_select "span.moderation-notice", false
    assert_select "#taginput[value=?]", "one,two"
  end

  test "newcomer should get post form" do
    UserSession.create(rusers(:newcomer))
    get :post
    assert_response :success
    assert_select "h3", "Share your work"
    assert_select "p.moderation-notice", "Hi! Just letting you know ahead of time that everyone's first posts to this website are moderated due to issues we've had with spam. Thanks for your patience!"
  end

  test "should redirect to login page while posting  question" do
    get :post,
        tags: 'question:question',
        template: 'question',
        redirect: 'question'
    assert_redirected_to '/login'
    # uses ASCII format instead of utf-8
    assert_equal "/post?redirect=question&tags=question%3Aquestion&template=question", session[:return_to]
  end

  test "should show question template in post form for questions" do
    UserSession.create(rusers(:bob))
    get :post,
        tags: 'question:question,one',
        template: 'question',
        redirect: 'question'
      assert_response :redirect
<<<<<<< HEAD
      assert_redirected_to '/questions/new'
=======
      assert_redirected_to '/questions/new?redirect=question&tags=question%3Aquestion%2Cone&template=question'
>>>>>>> 2e77bd95c9873daa8608b348e891c27daf34ac2f
      # assert_select "h3", "Ask a question of the community"
      # assert_select "input#taginput[value=?]", "question:question,one"
  end

  test "should show title form input if title parameter present" do
    UserSession.create(rusers(:bob))
    get :post,
        title: 'New Question'
    assert_response :success
    assert_select "input#title" do
    assert_select "[value=?]", "New Question"
    end
  end
end
