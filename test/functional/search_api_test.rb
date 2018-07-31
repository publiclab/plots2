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

     assert_equal nodes(:blog).path, json['items'][0]['docUrl']
     assert_equal "Blog post",       json['items'][0]['docTitle']
     assert_equal 13,                json['items'][0]['docId']

     assert matcher =~ json

   end

   test 'search all functionality with multiple responses' do
      get '/api/srch/all?srchString=question'
      assert last_response.ok?

      # Expected search pattern
      pattern = {
        srchParams: {
          srchString: 'question',
          seq: nil,
        }.ignore_extra_keys!
      }.ignore_extra_keys!

      matcher = JsonExpressions::Matcher.new(pattern)

      json = JSON.parse(last_response.body)

      assert_equal 15,               json['items'][0]['docId']
      assert_equal 9,                json['items'][1]['docId']
      assert_equal 15,               json['items'][2]['docId']
      assert_equal 9,                json['items'][3]['docId']

      assert matcher =~ json

    end

    test 'search all functionality without search query' do
       get '/api/srch/all?srchString'
       assert last_response.ok?

       # Expected search pattern
       pattern = {
         srchParams: {
           srchString: nil,
           seq: nil,
         }.ignore_extra_keys!
       }.ignore_extra_keys!

       matcher = JsonExpressions::Matcher.new(pattern)

       json = JSON.parse(last_response.body)
       assert matcher =~ json

     end

   # returns users by id when order_by is not provided and sorted direction default DESC
   test 'search profiles without order_by and default sort_direction' do
     get '/api/srch/profiles?srchString=steff'
     assert last_response.ok?

     # Expected search pattern
     pattern = {
       srchParams: {
         srchString: 'steff',
         seq: nil,
       }.ignore_extra_keys!
     }.ignore_extra_keys!

     matcher = JsonExpressions::Matcher.new(pattern)

     json = JSON.parse(last_response.body)

     assert_equal "/profile/steff3",   json['items'][0]['docUrl']
     assert_equal "/profile/steff2",   json['items'][1]['docUrl']
     assert_equal "/profile/steff1",   json['items'][2]['docUrl']

     assert matcher =~ json

   end

   # returns users sorteded by recent activity and order direction default DESC
   test 'search recent profiles with sort_by=recent present' do
     get '/api/srch/profiles?srchString=steff&sort_by=recent'
     assert last_response.ok?

     # Expected search pattern
     pattern = {
       srchParams: {
         srchString: 'steff',
         seq: nil
       }.ignore_extra_keys!
     }.ignore_extra_keys!

     matcher = JsonExpressions::Matcher.new(pattern)

     json = JSON.parse(last_response.body)

     assert_equal "steff3",     json['items'][0]['docTitle']
     assert_equal "steff2",     json['items'][1]['docTitle']
     assert_equal "steff1",     json['items'][2]['docTitle']

     assert matcher =~ json
   end

   # returns users ordered by recent activity and sorted by ASC direction
   test 'search recent profiles with sort_by=recent present and order_direction ASC' do
     get '/api/srch/profiles?srchString=steff&sort_by=recent&order_direction=ASC'
     assert last_response.ok?

     # Expected search pattern
     pattern = {
       srchParams: {
         srchString: 'steff',
         seq: nil
       }.ignore_extra_keys!
     }.ignore_extra_keys!

     matcher = JsonExpressions::Matcher.new(pattern)

     json = JSON.parse(last_response.body)

     assert_equal "/profile/steff1",     json['items'][0]['docUrl']
     assert_equal "/profile/steff2",     json['items'][1]['docUrl']
     assert_equal "/profile/steff3",     json['items'][2]['docUrl']

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

  test 'search Tag Nearby Nodes functionality' do
    get '/api/srch/taglocations?srchString=71.00,52.00&tagName=awesome'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
        srchParams: {
            srchString: '71.00,52.00',
            tagName: 'awesome',
            seq: nil,
        }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

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
    assert_equal "people_coordinates", json['items'][0]['docType']
    assert_equal 1,                    json['items'][0]['docId']

    assert matcher =~ json

  end

  test 'search recent people functionality having specified tagName' do
    get '/api/srch/peoplelocations?srchString=100&tagName=tool:barometer'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
        srchParams: {
            srchString: '100',
            tagName: 'tool:barometer',
            seq: nil,
        }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert_equal users(:bob).username, json['items'][0]['docTitle']
    assert_equal "people_coordinates", json['items'][0]['docType']
    assert_equal 1,                    json['items'][0]['docId']

    assert matcher =~ json

  end

end
