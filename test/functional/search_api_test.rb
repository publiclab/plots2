require 'test_helper'

class SearchApiTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  test 'search all functionality' do
    get '/api/srch/all?srchString=Blog'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        srchString: 'Blog',
        seq: nil,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert_equal node(:blog).path, json['items'][0]['docUrl']
    assert_equal "Blog post",       json['items'][0]['docTitle']
    assert_equal 13,                json['items'][0]['docId']

    assert matcher =~ json

  end

  test 'search notes functionality' do
    get '/api/srch/notes?srchString=Blog'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        srchString: 'Blog',
        seq: nil,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert_equal node(:blog).path, json['items'][0]['docUrl']
    assert_equal "Blog post",       json['items'][0]['docTitle']
    assert_equal 13,                json['items'][0]['docId']

    assert matcher =~ json

  end

  test 'search profiles functionality' do
    get '/api/srch/profiles?srchString=Blog'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        srchString: 'Blog',
        seq: nil,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert matcher =~ json

  end

  test 'search questions functionality' do
    get '/api/srch/questions?srchString=Blog'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        srchString: 'Blog',
        seq: nil,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert matcher =~ json

  end

  test 'search tags functionality' do
    get '/api/srch/tags?srchString=Blog'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        srchString: 'Blog',
        seq: nil,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert matcher =~ json

  end

end
