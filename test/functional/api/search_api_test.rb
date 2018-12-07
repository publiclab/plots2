require 'test_helper'

class SearchApiTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

   # search by username and returns users by id when order_by is not provided and sorted direction default DESC
   test 'search profiles by username without order_by and default sort_direction' do
     get '/api/srch/profiles?query=steff&field=username'
     assert last_response.ok?

     # Expected search pattern
     pattern = {
       srchParams: {
         query: 'steff',
         seq: nil,
       }.ignore_extra_keys!
     }.ignore_extra_keys!

     matcher = JsonExpressions::Matcher.new(pattern)

     json = JSON.parse(last_response.body)

     assert_equal "/profile/steff3",   json['items'][0]['doc_url']
     assert_equal "/profile/steff2",   json['items'][1]['doc_url']
     assert_equal "/profile/steff1",   json['items'][2]['doc_url']

     assert matcher =~ json

   end

   # search by username and returns users sorteded by recent activity and order direction default DESC
   test 'search recent profiles by username with sort_by=recent present' do
     get '/api/srch/profiles?query=steff&field=username&sort_by=recent'
     assert last_response.ok?

     # Expected search pattern
     pattern = {
       srchParams: {
         query: 'steff',
         seq: nil
       }.ignore_extra_keys!
     }.ignore_extra_keys!

     matcher = JsonExpressions::Matcher.new(pattern)

     json = JSON.parse(last_response.body)

     assert_equal "steff2",     json['items'][0]['doc_title']
     assert_equal "steff3",     json['items'][1]['doc_title']
     assert_equal "steff1",     json['items'][2]['doc_title']

     assert matcher =~ json
   end

   # search by username and returns users ordered by recent activity and sorted by ASC direction
   test 'search recent profiles by username with sort_by=recent present and order_direction ASC' do
     get '/api/srch/profiles?query=steff&field=username&sort_by=recent&order_direction=ASC'
     assert last_response.ok?

     # Expected search pattern
     pattern = {
       srchParams: {
         query: 'steff',
         seq: nil
       }.ignore_extra_keys!
     }.ignore_extra_keys!

     matcher = JsonExpressions::Matcher.new(pattern)

     json = JSON.parse(last_response.body)

     assert_equal "/profile/steff1",     json['items'][0]['doc_url']
     assert_equal "/profile/steff3",     json['items'][1]['doc_url']
     assert_equal "/profile/steff2",     json['items'][2]['doc_url']

     assert matcher =~ json
  end

  test 'search tags functionality' do
    get '/api/srch/tags?query=Awesome'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        query: 'Awesome',
        seq: nil,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)
    assert matcher =~ json
  end

  test 'search Tag Nearby Nodes functionality with a valid query' do
    get '/api/srch/taglocations?query=71.00,52.00'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
        srchParams: {
            query: '71.00,52.00',
            seq: nil,
        }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert matcher    =~ json
    assert_equal 13,  json['items'][0]['doc_id']
  end

  test 'search Tag Nearby People functionality' do
    get '/api/srch/nearbyPeople?query=31.00,40.00'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
        srchParams: {
            query: '31.00,40.00',
            seq: nil
        }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert_equal "/profile/steff3",     json['items'][0]['doc_url']
    assert_equal "/profile/steff2",     json['items'][1]['doc_url']

    assert matcher =~ json
  end

  test 'search Tag Nearby People functionality wth sort_by=recent' do
    get '/api/srch/nearbyPeople?query=31.00,40.00&sort_by=recent'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
        srchParams: {
            query: '31.00,40.00',
            seq: nil
        }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert_equal "/profile/steff2",     json['items'][0]['doc_url']
    assert_equal "/profile/steff3",     json['items'][1]['doc_url']

    assert matcher =~ json
  end

  test 'search Tag Nearby People functionality with tag=awesome' do
    get '/api/srch/nearbyPeople?query=31.00,40.00&tag=awesome'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
        srchParams: {
            query: '31.00,40.00',
            tag: 'awesome',
            seq: nil
        }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert_equal "/profile/steff3",     json['items'][0]['doc_url']

    assert matcher =~ json
  end

  test 'search Recent People functionality' do
    get '/api/srch/peoplelocations?query=100'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
        srchParams: {
            query: '100',
            seq: nil,
        }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert_equal users(:bob).username, json['items'][0]['doc_title']
    assert_equal "PLACES",             json['items'][0]['doc_type']
    assert_equal 1,                    json['items'][0]['doc_id']

    assert matcher =~ json

  end

  test 'search recent people functionality having specified tagName' do
    get '/api/srch/peoplelocations?query=100&tag=tool:barometer'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
        srchParams: {
            query: '100',
            tag: 'tool:barometer',
            seq: nil,
        }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert_equal users(:bob).username, json['items'][0]['doc_title']
    assert_equal "PLACES",             json['items'][0]['doc_type']
    assert_equal 1,                    json['items'][0]['doc_id']

    assert matcher =~ json

  end
end
