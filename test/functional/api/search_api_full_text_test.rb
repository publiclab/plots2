require 'test_helper'
require "minitest/autorun"

class SearchApiFullTextTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def search_all_functionality
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
    get '/api/srch/all?query=Blog'

    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        query: 'Blog',
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
    get '/api/srch/all?query=question'

    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        query: 'question',
        seq: nil,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)
    json = JSON.parse(last_response.body)

    assert matcher =~ json
  end

  def search_all_functionality_without_search_query
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
    get '/api/srch/all?query'

    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        query: nil,
        seq: nil,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

     matcher = JsonExpressions::Matcher.new(pattern)
     json = JSON.parse(last_response.body)

     assert matcher =~ json
   end

  def search_profiles_by_username_and_bio_without_order_by_and_default_sort_direction
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
    get '/api/srch/profiles?query=steff'

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

    assert_equal "/profile/data",     json['items'][0]['doc_url']
    assert_equal "/profile/steff3",   json['items'][1]['doc_url']
    assert_equal "/profile/steff2",   json['items'][2]['doc_url']
    assert_equal "/profile/steff1",   json['items'][3]['doc_url']

    assert matcher =~ json
  end

  def search_profiles_by_bio_without_order_by_and_default_sort_direction
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
    get '/api/srch/profiles?query=ruby'

    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        query: 'ruby',
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
    get '/api/srch/questions?query=Question'

    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        query: 'Question',
        seq: nil,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)
    json = JSON.parse(last_response.body)

    assert_equal "How to use a Spectrometer",   json['items'][0]['doc_title']
    assert_equal 8,                             json['items'][0]['doc_id']

    assert matcher =~ json

  end

  def search_notes_functionality
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'
    get '/api/srch/notes?query=Blog'

    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        query: 'Blog',
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
