require 'test_helper'

class SortByTagsTest < ActionDispatch::IntegrationTest
  test "sort question by tags" do
    get '/questions'
    assert_response :success

    get '/tag/add_tag', name: "test,question:spectrometer", return_to: request.path
    assert_not_nil session[:tags]
    follow_redirect!
    assert_equal '/questions', path
    assert_not_nil assigns(:questions)
    questions = assigns(:questions)
    expected = [node(:question), node(:question2)]
    assert (expected & questions).present?

    tag = tags(:question)
    get '/tag/remove_tag/' + tag.tid.to_s, return_to: request.path
    follow_redirect!
    assert_equal '/questions', path
    questions = assigns(:questions)
    expected = [node(:question)]
    assert (expected & questions).present?
    assert !([node(:question2)] & questions).present?

    get '/tag/remove_all_tags', return_to: request.path
    follow_redirect!
    assert_equal '/questions', path
    assert_empty session[:tags]
    questions = assigns(:questions)
    expected = [node(:question), node(:question2)]
    assert (expected & questions).present?
  end

end
