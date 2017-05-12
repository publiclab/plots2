require 'test_helper'

class SearchRecordTest < ActiveSupport::TestCase

  test "search record creation" do

    search = SearchRecord.new({
      key_words: 'balloon'
    })

    assert search.save

    search = SearchRecord.find search.id

    assert_not_nil search
    assert_not_nil search.id
    assert_equal 'balloon', search.key_words

  end

  test "search record solr_search run" do

    search = SearchRecord.new({
      key_words: 'spectrometer'
    })

    assert search.save

    assert_not_nil search.notes(nil)

  end

  test "plain Node.search returns something"
    search = Node.search
    assert_not_nil search.results
    assert search.results.length > 0
  end

  test "Node.search for two different key words returns different results" do
    solr_search_1 = Node.search do
      fulltext 'spectro'
      with(:updated_at).less_than(Time.zone.now)
      #facet(:updated_month)
      #with(:updated_month, month) if month.present?
      #paginate :page => 1, :per_page => 10
    end
    solr_search_2 = Node.search do
      fulltext 'Chicago'
      with(:updated_at).less_than(Time.zone.now)
      #facet(:updated_month)
      #with(:updated_month, month) if month.present?
      #paginate :page => 1, :per_page => 10
    end
    assert_not_nil solr_search_1.results.length > 0
    assert_not_nil solr_search_2.results.length > 0
    assert_not_equal solr_search_1.results.collect(&:nid), solr_search_2.results.collect(&:nid)
    assert_equal 8, solr_search_1.results[0].nid
    assert_equal 7, solr_search_2.results[0].nid
  end

end
