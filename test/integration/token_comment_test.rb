require 'test_helper'

class TokenCommentTest < ActionDispatch::IntegrationTest
  test 'should not post comment through invalid token successfully' do
    @params = {
      body: 'Test Comment',
      username: 'Bob'
    }

    @headers = {
      'HTTP_TOKEN' => 'invalid-token'
    }

    post '/comment/create/token/1.json', @params, @headers
    assert_response :unauthorized
  end

  test 'should not post an invalid comment successfully' do
    @params = {
      body: '',
      username: 'Bob'
    }

    @headers = {
      'HTTP_TOKEN' => 'abcdefg12345'
    }

    post '/comment/create/token/1.json', @params, @headers
    assert_response :bad_request
  end

  test 'should post comment through valid token successfully' do
    @params = {
      body: 'Test Comment',
      username: 'Bob'
    }

    @headers = {
      'HTTP_TOKEN' => 'abcdefg12345'
    }

    post '/comment/create/token/1.json', @params, @headers
    assert_response :success
  end

end
