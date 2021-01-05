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

  test 'running search notes' do
    params = {query: 'Blog' }
    search_criteria = SearchCriteria.new(params)

    result = SearchService.new.search_notes(search_criteria.query)

    assert_not_nil result
    assert_equal result.size, 1
  end

  test 'running search content' do
    params = {query: 'Blog' }
    search_criteria = SearchCriteria.new(params)

    result = SearchService.new.search_content(search_criteria.query, 10) # limit

    assert_not_nil result
    assert_equal 2, result.size
  end

  test 'running search nodes' do
    params = {query: 'Blog post alias title' }
    search_criteria = SearchCriteria.new(params)

    result = SearchService.new.search_nodes(search_criteria.query)
    p result
    result.each do |node|
      puts node.title
    end
    assert_not_nil result
    assert_equal 1, result.size
  end

  test 'running search tags' do

    result = SearchService.new.search_tags('awesome')

    assert_not_nil result
    assert_equal result.size, 1
  end

  test 'running search questions' do
    result = SearchService.new.search_questions('question')

    assert_not_nil result
    assert_equal 4, result.size
  end

  test 'running search taglocations with a wrong param format raises an exception' do
    exception = assert_raises(Exception) { SearchService.new.tagNearbyNodes('30:40', nil) }
    assert_equal( "Must contain all four coordinates", exception.message )
  end

  test 'running search taglocations with invalid params' do
    exception_1 = assert_raises(Exception) { SearchService.new.tagNearbyNodes({ "nwlat" =>'43', "nwlng" =>'43', "selat" =>'43', "selng" =>'43' }, nil) }

    assert_equal( "Must be a float", exception_1.message )
  end

  test 'running search taglocations with valid params' do
    result_1 = SearchService.new.tagNearbyNodes({ "nwlat" => 80.0, "nwlng" => 50.0, "selat" => 70.0, "selng" =>60.0 }, nil)

    assert_not_nil result_1

    assert_equal result_1.length, 2
  end

  test 'running search taglocations with valid params and specific period' do
    result_1 = SearchService.new.tagNearbyNodes({ "nwlat" => 180.0, "nwlng" => 0.0, "selat" => 0.0, "selng" =>180.0 }, nil, period = { "from" => nil, "to" => Date.new(2018, 12, 01)}, sort_by = nil, order_direction = nil, limit = 10)
    assert_not_nil result_1
    assert_equal result_1.length, 3
  end

  test 'running search taglocations with invalid period' do
    exception_1 = assert_raises(Exception) { SearchService.new.tagNearbyNodes({ "nwlat" => 180.0, "nwlng" => 0.0, "selat" => 0.0, "selng" =>180.0 }, nil, period = { "from" => nil, "to" => 'date'}, sort_by = nil, order_direction = nil, limit = 10) }
    assert_equal( "If 'to' is not null, must contain date", exception_1.message )
  end

  test 'running profiles by usertags' do
    users = [users(:steff3), users(:steff2), users(:steff1)]

    params = { query: 'awesome', field: 'tag' }
    search_criteria = SearchCriteria.new(params)
    result = SearchService.new.search_profiles(search_criteria)

    assert_not_nil result
    assert_equal result.size, 1
  end

  test 'running search nearby people with invalid period' do
    exception_1 = assert_raises(Exception) { SearchService.new.tagNearbyPeople({ "nwlat" => 180.0, "nwlng" => 0.0, "selat" => 0.0, "selng" =>180.0 }, nil, nil, period = { "from" => nil, "to" => 'date'}, sort_by = nil, order_direction = nil, limit = 10) }
    assert_equal( "If 'to' is not null, must contain date", exception_1.message )
  end
end
