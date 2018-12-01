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
    assert_equal result.size, 3
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

  test 'running search taglocations with a wrong param format raises an exception' do
    exception = assert_raises(Exception) { SearchService.new.tagNearbyNodes('30:40', nil) }
    assert_equal( "Must separate coordinates with ,", exception.message )
  end

  test 'running search taglocations with invalid params' do
    exception_1 = assert_raises(Exception) { SearchService.new.tagNearbyNodes('43,71', nil) }
    exception_2 = assert_raises(Exception) { SearchService.new.tagNearbyNodes('4,7', nil) }

    assert_equal( "Must have at least one digit after .", exception_1.message )
    assert_equal( "Must have at least one digit after .", exception_2.message )
  end

  test 'running search taglocations with valid params' do
    result_1 = SearchService.new.tagNearbyNodes('71.00,52.00', nil)
    result_2 = SearchService.new.tagNearbyNodes('71.0,52.0', nil)

    assert_not_nil result_1
    assert_not_nil result_2

    assert_equal result_1.size, 1
    assert_equal result_2.size, 1
  end
end
