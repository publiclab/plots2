require 'test_helper'
require "minitest/autorun"

class SearchServiceTest < ActiveSupport::TestCase
  test 'running profiles for specific username' do
    users = [users(:steff1)]

    params = { query: 'steff1' }
    search_criteria = SearchCriteria.new(params)

    result = SearchService.new.search_profiles(search_criteria)

    assert_not_nil result
    assert_equal result.size, 1
  end

  test 'running profiles by username' do
    users = [users(:steff3), users(:steff2), users(:steff1)]

    params = { query: 'steff', field: 'username' }
    search_criteria = SearchCriteria.new(params)

    result = SearchService.new.search_profiles(search_criteria)

    assert_not_nil result
    assert_equal result.size, 3
  end

  test 'running people locations' do
    result = SearchService.new.people_locations('10', limit = nil)

    assert_not_nil result
    assert_equal result.size, 1
  end

  test 'running search notes' do
    params = {query: 'Blog' }
    search_criteria = SearchCriteria.new(params)

    result = SearchService.new.search_notes(search_criteria.query)

    assert_not_nil result
    assert_equal result.size, 1

  end

  test 'running search tags' do

    result = SearchService.new.search_tags('awesome')

    assert_not_nil result
    assert_equal result.size, 4
  end

  test 'running search questions' do
    result = SearchService.new.search_questions('question')

    assert_not_nil result
    assert_equal result.size, 3
  end
end
