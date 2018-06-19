require 'test_helper'

class TokenCommentTest < ActionDispatch::IntegrationTest
  test 'should not post comment through invalid token successfully' do
    post '/comment/create/token/1.json', params: { body: 'Test Comment', username: 'Bob' }, headers: { 'HTTP_TOKEN' => 'invalid-token' }
    assert_response :unauthorized
  end

  test 'should not post an invalid comment successfully' do
    post '/comment/create/token/1.json', params: { body: '', username: 'Bob' }, headers: { 'HTTP_TOKEN' => 'abcdefg12345' }
    assert_response :bad_request
  end

  test 'should post comment through valid token successfully' do
    post '/comment/create/token/1.json', params: { body: 'Test Comment', username: 'Bob' }, headers: { 'HTTP_TOKEN' => 'abcdefg12345' }
    assert_response :success
  end
end
