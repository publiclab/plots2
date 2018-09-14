require 'test_helper'
require "minitest/autorun"

class SearchServiceFullTextSearchTest < ActiveSupport::TestCase

  def create_profiles_doc_list(list)
    sresult = DocList.new
    list.each do |match|
      doc = DocResult.fromSearch(0, 'user', '/profile/' + match.name, match.name, 'USERS', 0)
      sresult.addDoc(doc)
    end
    sresult
  end

  def create_notes_doc_list(notes)
    sresult = DocList.new
    notes.each do |match|
      doc = DocResult.fromSearch(match.nid, 'file', match.path, match.title, 'NOTES', 0)
      sresult.addDoc(doc)
    end
    sresult
  end

  def create_questions_doc_list(notes)
    sresult = DocList.new
    notes.each do |match|
      doc = DocResult.fromSearch(match.nid, 'question-circle', match.path(:question), match.title, 'QUESTIONS', match.answers.length.to_i)
      sresult.addDoc(doc)
    end
    sresult
  end

  def running_profiles_by_username_and_bio
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'

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

  def running_search_notes
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'

    notes = [nodes(:blog)]
    sresult = create_notes_doc_list(notes)

    result = SearchService.new.textSearch_notes('Blog')

    assert_not_nil result
    assert_equal 1, result.items.length

    assert_equal result.getDocs.to_json, sresult.getDocs.to_json
    assert_equal result.getDocs.to_json.length, result.getDocs.uniq.to_json.length
  end

  def running_search_questions
    skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'

    notes = [nodes(:question), nodes(:question2), nodes(:question3)]
    sresult = create_questions_doc_list(notes)

    result = SearchService.new.textSearch_questions('question')

    assert_not_nil result
    assert_equal 3, result.items.length

    assert_equal result.getDocs.to_json, sresult.getDocs.to_json
    assert_equal result.getDocs.to_json.length, result.getDocs.uniq.to_json.length
  end
end
