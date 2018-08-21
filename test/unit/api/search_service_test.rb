require 'test_helper'
require "minitest/autorun"

class SearchServiceTest < ActiveSupport::TestCase

  def create_profiles_doc_list(list)
    sresult = DocList.new
    list.each do |match|
      doc = DocResult.fromSearch(0, 'user', '/profile/' + match.name, match.name, '', 0)
      sresult.addDoc(doc)
    end
    sresult
  end

  def create_profiles_doc_list_location(list)
    sresult = DocList.new
    list.each do |user|
      blurred = user.has_power_tag("location") ? user.get_value_of_power_tag("location") : false
      doc = DocResult.fromLocationSearch(user.id, 'people_coordinates', user.path, user.username, 0, 0, user.lat, user.lon, blurred)
      sresult.addDoc(doc)
    end
    sresult
  end

  test 'running profiles for specific username' do


    users = [users(:steff1)]
    sresult = create_profiles_doc_list(users)

    params = { srchString: 'steff1' }
    search_criteria = SearchCriteria.new(params)

    result = SearchService.new.profiles(search_criteria)

    assert_not_nil result
    assert_equal result.getDocs.size, 1

    assert_equal result.getDocs.to_json, sresult.getDocs.to_json
    assert_equal result.getDocs.to_json.length, result.getDocs.uniq.to_json.length

  end

  test 'running profiles by username' do
    users = [users(:steff3), users(:steff2), users(:steff1)]
    sresult = create_profiles_doc_list(users)

    params = { srchString: 'steff', field: 'username' }
    search_criteria = SearchCriteria.new(params)

    result = SearchService.new.profiles(search_criteria)

    assert_not_nil result
    assert_equal result.getDocs.size, 3

    assert_equal result.getDocs.to_json, sresult.getDocs.to_json
    assert_equal result.getDocs.to_json.length, result.getDocs.uniq.to_json.length
  end

  test 'running profiles by username and bio' do
    # User.search() only works for mysql/mariadb
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      users = [users(:data), users(:steff3), users(:steff2), users(:steff1)]
      sresult = create_profiles_doc_list(users)

      params = { srchString: 'steff' }
      search_criteria = SearchCriteria.new(params)

      result = SearchService.new.profiles(search_criteria)

      assert_not_nil result
      assert_equal result.getDocs.size, 4

      assert_equal result.getDocs.to_json, sresult.getDocs.to_json
      assert_equal result.getDocs.to_json.length, result.getDocs.uniq.to_json.length
    end
  end

  test 'running people locations' do
    users = [users(:bob)]
    sresult = create_profiles_doc_list_location(users)

    result = SearchService.new.people_locations('10', limit = nil)

    assert_not_nil result
    assert_equal 1, result.items.length

    assert_equal result.getDocs.to_json, sresult.getDocs.to_json
    assert_equal result.getDocs.to_json.length, result.getDocs.uniq.to_json.length
  end
end
