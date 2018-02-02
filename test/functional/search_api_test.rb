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

     assert_equal nodes(:blog).path,  json['items'][0]['docUrl']
     assert_equal "Blog post",       json['items'][0]['docTitle']
     assert_equal 13,                json['items'][0]['docId']

     assert matcher =~ json

   end

   test 'search profiles functionality' do
     get '/api/srch/profiles?srchString=Jeff'
     assert last_response.ok?

     # Expected search pattern
     pattern = {
       srchParams: {
         srchString: 'Jeff',
         seq: nil,
       }.ignore_extra_keys!
     }.ignore_extra_keys!

     matcher = JsonExpressions::Matcher.new(pattern)

     json = JSON.parse(last_response.body)

     assert_equal "/profile/jeff", json['items'][0]['docUrl']
     assert_equal "jeff",          json['items'][0]['docTitle']
     assert_equal "user",               json['items'][0]['docType']

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

      assert_equal nodes(:blog).path, json['items'][0]['docUrl']
      assert_equal "Blog post",       json['items'][0]['docTitle']
      assert_equal 13,                json['items'][0]['docId']

      assert matcher =~ json

    end

    test 'search questions functionality' do
       get '/api/srch/questions?srchString=Question'
       assert last_response.ok?

       # Expected search pattern
       pattern = {
         srchParams: {
           srchString: 'Question',
           seq: nil,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert_equal "Question by a moderated user",   json['items'][0]['docTitle']
    assert_equal 15,                               json['items'][0]['docId']


    assert matcher =~ json

  end

  test 'search tags functionality' do
     get '/api/srch/tags?srchString=Awesome'
     assert last_response.ok?

     # Expected search pattern
     pattern = {
       srchParams: {
         srchString: 'Awesome',
          seq: nil,
       }.ignore_extra_keys!
     }.ignore_extra_keys!

     matcher = JsonExpressions::Matcher.new(pattern)

     json = JSON.parse(last_response.body)
     assert matcher =~ json

    end

  test 'search nearby nodes functionality' do
    get '/api/srch/locations?srchString=71.00,52.00'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
        srchParams: {
            srchString: '71.00,52.00',
            seq: nil,
        }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert_equal nodes(:blog).path, json['items'][0]['docUrl']
    assert_equal "Blog post",       json['items'][0]['docTitle']
    assert_equal 13,                json['items'][0]['docId']

    assert matcher =~ json

  end

  test 'search Recent People functionality' do
    get '/api/srch/peoplelocations?srchString=100'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
        srchParams: {
            srchString: '100',
            seq: nil,
        }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert_equal users(:bob).username, json['items'][0]['docTitle']
    assert_equal "people_coordinates",       json['items'][0]['docType']
    assert_equal 1,                json['items'][0]['docId']

    assert matcher =~ json

  end

end
