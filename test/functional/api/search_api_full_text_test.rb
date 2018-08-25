require 'test_helper'
require "minitest/autorun"

class SearchApiFullTextTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
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

    assert_equal "/profile/data",     json['items'][0]['docUrl']
    assert_equal "/profile/steff3",   json['items'][1]['docUrl']
    assert_equal "/profile/steff2",   json['items'][2]['docUrl']
    assert_equal "/profile/steff1",   json['items'][3]['docUrl']

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

    assert_equal "/profile/testuser",   json['items'][0]['docUrl']

    assert matcher =~ json
  end
end
