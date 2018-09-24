require 'test_helper'
require "minitest/autorun"

class SearchApiFullTextTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def search_all_functionality
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
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

    assert_equal nodes(:blog).path, json['items'][0]['doc_url']
    assert_equal "Blog post",       json['items'][0]['doc_title']
    assert_equal 13,                json['items'][0]['doc_id']

    assert matcher =~ json
  end

  def search_all_functionality_with_multiple_responses
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
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

    assert matcher =~ json
  end

  def search_all_functionality_without_search_query
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
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

  def search_profiles_by_username_and_bio_without_order_by_and_default_sort_direction
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
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

    assert_equal "/profile/data",     json['items'][0]['doc_url']
    assert_equal "/profile/steff3",   json['items'][1]['doc_url']
    assert_equal "/profile/steff2",   json['items'][2]['doc_url']
    assert_equal "/profile/steff1",   json['items'][3]['doc_url']

    assert matcher =~ json
  end

  def search_profiles_by_bio_without_order_by_and_default_sort_direction
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
    get '/api/srch/profiles?srchString=ruby'

    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        srchString: 'ruby',
        seq: nil,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)
    json = JSON.parse(last_response.body)

    assert_equal "/profile/testuser",   json['items'][0]['doc_url']

    assert matcher =~ json
  end

  def search_questions_functionality
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
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

    assert_equal "How to use a Spectrometer", json['items'][0]['docTitle']
    assert_equal 8,                             json['items'][0]['docId']

    assert matcher =~ json

  end

  def search_notes_functionality
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
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

    assert_equal nodes(:blog).path, json['items'][0]['doc_url']
    assert_equal "Blog post",       json['items'][0]['doc_title']
    assert_equal 13,                json['items'][0]['doc_id']

    assert matcher =~ json
  end
end
