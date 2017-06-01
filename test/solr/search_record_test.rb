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

  test "plain Node.search returns something" do
    search = Node.search
    assert_not_nil search.results
puts assert_not_nil search.results.inspect
    assert search.results.length > 0
  end

  test "Node.search for two different key words returns different results" do
    solr_search_1 = Node.search do
      fulltext 'Chicago'
      #with(:updated_at).less_than(Time.zone.now)
      # this is required to get results to return: 
      adjust_solr_params do |params|
        params[:qf] = nil
      end
      #facet(:updated_month)
      #with(:updated_month, month) if month.present?
      #paginate :page => 1, :per_page => 10
    end
    solr_search_2 = Node.search do
      fulltext 'pectro' # intending case-insensitive search for "spectrometer" or similar
      #with(:updated_at).less_than(Time.zone.now)
      # this is required to get results to return: 
      adjust_solr_params do |params|
        params[:qf] = nil
      end
      #facet(:updated_month)
      #with(:updated_month, month) if month.present?
      #paginate :page => 1, :per_page => 10
    end
puts solr_search_1.results
puts solr_search_2.results
    assert solr_search_1.results.length > 0
    assert solr_search_2.results.length > 0
    assert_not_equal solr_search_1.results.collect(&:nid), solr_search_2.results.collect(&:nid)
    assert_equal 8, solr_search_1.results[0].nid
    assert_equal 7, solr_search_2.results[0].nid
  end

end
