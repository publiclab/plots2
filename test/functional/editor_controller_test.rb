require 'test_helper'

class EditorControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test "should not get legacy form if not logged in" do
    get :legacy
    assert_redirected_to '/login'
  end

  test "should get legacy form" do
    UserSession.create(rusers(:bob))
    get :legacy,
        tags: 'one,two'
    assert_response :success
    assert_select "h3", "Share your work"
    assert_select "span.moderation-notice", false
    assert_select "#taginput[value=?]", "one,two"
  end

  test "should get post form" do
    UserSession.create(rusers(:bob))
    get :post
      assert_response :success
      assert_select "h1", "Share"
      assert_select "p.ple-help", "Select an optional main image for your post."
  end

  test "should use existing node body as template in legacy form based on param 'n'" do
    UserSession.create(rusers(:bob))
    get :legacy,
        n: node(:blog).id
    assert_response :success
    assert_select "textarea#text-input", node(:blog).body
  end

  test "should use existing node body as template in legacy form based on param 'n' in rich editor" do
    UserSession.create(rusers(:bob))
    get :rich,
        n: node(:blog).id
    assert_response :success
    assert_select "textarea#text-input", node(:blog).body
  end

  test "newcomer should get legacy form" do
    UserSession.create(rusers(:newcomer))
    get :legacy
    assert_response :success
    assert_select "h3", "Share your work"
    assert_select "p.moderation-notice", "Hi! Just letting you know ahead of time that everyone's first posts to this website are moderated due to issues we've had with spam. Thanks for your patience!"
  end

  test "should redirect to login page while posting  question" do
    get :legacy,
        tags: 'question:question',
        template: 'question',
        redirect: 'question'
    assert_redirected_to '/login'
    # uses ASCII format instead of utf-8
    assert_equal "/legacy?redirect=question&tags=question%3Aquestion&template=question", session[:return_to]
  end

  test "should show question template in legacy form for questions" do
    UserSession.create(rusers(:bob))
    get :legacy,
        tags: 'question:question,one',
        template: 'question',
        redirect: 'question'
      assert_response :redirect
      assert_redirected_to '/questions/new?redirect=question&tags=question%3Aquestion%2Cone&template=question'
      # assert_select "h3", "Ask a question of the community"
      # assert_select "input#taginput[value=?]", "question:question,one"
  end

  test "should show title form input if title parameter present" do
    UserSession.create(rusers(:bob))
    get :legacy,
        title: 'New Question'
    assert_response :success
    assert_select "input#title" do
    assert_select "[value=?]", "New Question"
    end
  end
end
