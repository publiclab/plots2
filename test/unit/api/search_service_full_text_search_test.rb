require 'test_helper'
require "minitest/autorun"

class SearchServiceFullTextSearchTest < ActiveSupport::TestCase

  def running_profiles_by_username_and_bio
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'

    users = [users(:data), users(:steff3), users(:steff2), users(:steff1)]

    params = { query: 'steff' }
    search_criteria = SearchCriteria.new(params)

    result = SearchService.new.search_profiles(search_criteria)

    assert_not_nil result
    assert_equal result.size, 4
  end


  def running_search_notes
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'

    notes = [nodes(:blog)]
    result = SearchService.new.search_notes('Blog')

    assert_not_nil result
    assert_equal result.size, 1
  end

  def running_search_questions
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'

    notes = [nodes(:question), nodes(:question2), nodes(:question3)]

    result = SearchService.new.search_questions('question')

    assert_not_nil result
    assert_equal result.size, 3
  end
end
