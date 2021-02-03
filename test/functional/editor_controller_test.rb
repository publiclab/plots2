require 'test_helper'

class EditorControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  test 'should not get legacy form if not logged in' do
    get :legacy
    assert_redirected_to '/login?return_to=/legacy'
  end

  test 'should not get post form if not logged in' do
    get :post
    assert_redirected_to '/login?return_to=/post'
  end

  test 'should not get editor form if not logged in' do
    get :editor
    assert_redirected_to '/login?return_to=/editor'
  end

  test 'should not get rich form if not logged in' do
    get :rich
    assert_redirected_to '/login?return_to=/editor/rich'
  end

  test 'should get legacy form' do
    UserSession.create(users(:bob))
    get :legacy,
        params: { 
        tags: 'one,two'
        }
    assert_response :success
    assert_select 'h3', 'Share your work'
    selector = css_select 'span.moderation-notice'
    assert_equal selector.size, 0
    assert_select '#taginput[value=?]', 'one,two'
    assert_select '#event-info'
  end

  test 'should get post form' do
    UserSession.create(users(:bob))
    get :post
    assert_response :success
    assert_select 'h1', 'Share'
    assert_select 'p', 'Select an optional main image for your post.'
  end

  test "should use existing node body as template in legacy form based on param 'n'" do
    UserSession.create(users(:bob))
    get :legacy,
        params: {
        n: nodes(:blog).id
        }
    assert_response :success
    assert_select 'textarea#text-input-main', nodes(:blog).body
  end

  test "should use existing node body as template in legacy form based on param 'n' in rich editor" do
    UserSession.create(users(:bob))
    get :rich,
        params: {
        n: nodes(:blog).id
        }
    assert_response :success
    assert_select 'textarea#text-input', nodes(:blog).body
  end

  test "should use existing node body as template in post form based on param 'n'" do
    UserSession.create(users(:bob))
    get :post,
        params: {
        n: nodes(:blog).id
        }
    assert_response :success
    assert_select 'textarea#text-input', nodes(:blog).body
  end

  test 'newcomer should get legacy form' do
    UserSession.create(users(:newcomer))
    get :legacy
    assert_response :success
    assert_select 'h3', 'Share your work'
    assert_select 'p', "Hi! Just letting you know ahead of time that everyone's first posts to this website are moderated due to issues we've had with spam. Thanks for your patience!"
  end

  test 'newcomer should get post form' do
    UserSession.create(users(:newcomer))
    get :post
    assert_response :success
    assert_select 'h1', 'Share'
    assert_select 'p', 'Select an optional main image for your post.'
  end

  test 'should redirect to login page while posting  question' do
    get :legacy,
        params: { 
        tags: 'question:question',
        template: 'question',
        redirect: 'question'
        }
    assert_redirected_to '/login?return_to=/legacy?redirect=question&tags=question%3Aquestion&template=question'
    # uses ASCII format instead of utf-8
    assert_equal '/legacy?redirect=question&tags=question%3Aquestion&template=question', session[:return_to]
  end

  test 'should show question template in legacy form for questions' do
    UserSession.create(users(:bob))
    get :legacy,
        params: {
        tags: 'question:question,one',
        template: 'question',
        redirect: 'question'
        }
    assert_response :redirect
    assert_redirected_to '/questions/new?redirect=question&tags=question%3Aquestion%2Cone&template=question'
    # assert_select "h3", "Ask a question of the community"
    # assert_select "input#taginput[value=?]", "question:question,one"
  end

  test 'should show question template in post form for questions' do
    UserSession.create(users(:bob))
    get :post,
        params: {
        tags: 'question:question,one',
        template: 'question',
        redirect: 'question'
        }
    assert_response :redirect
    assert_redirected_to '/questions/new?redirect=question&tags=question%3Aquestion%2Cone&template=question'
    # assert_select "h3", "Ask a question of the community"
    # assert_select "input#taginput[value=?]", "question:question,one"
  end

  test 'should show title form input if title parameter present' do
    UserSession.create(users(:bob))
    get :legacy,
        params: {
        title: 'New Question'
        }
    assert_response :success
    assert_select 'input#title' do
      assert_select '[value=?]', 'New Question'
    end
  end
end
