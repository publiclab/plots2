require 'test_helper'

class NodeSearchTest < ActiveSupport::TestCase

  Node.reindex
  Sunspot.commit

  test "plain Node.search returns something" do
    search = Node.search
    assert_not_nil search.results
    assert search.results.length > 0
  end

  test "Node.search for two different key words returns different results" do
    solr_search_1 = Node.search do
      fulltext 'Chicago' do
        fields(:title, :body) # can later add username, other fields, comments, maybe tags
      end
      #with(:updated_at).less_than(Time.zone.now)
      #facet(:updated_month)
      #with(:updated_month, month) if month.present?
      #paginate :page => 1, :per_page => 10
    end
    solr_search_2 = Node.search do
      fulltext 'Spectrometer' do # intending case-insensitive search for "spectrometer" or similar
        fields(:title, :body) # can later add username, other fields, comments, maybe tags
      end
      #with(:updated_at).less_than(Time.zone.now)
      #facet(:updated_month)
      #with(:updated_month, month) if month.present?
      #paginate :page => 1, :per_page => 10
    end
    assert solr_search_1.results.length > 0
    assert solr_search_2.results.length > 0
    assert_not_equal solr_search_1.results.collect(&:nid), solr_search_2.results.collect(&:nid)
    assert_equal nodes(:place).nid, solr_search_1.results[0].nid
    assert_equal nodes(:question).nid, solr_search_2.results[0].nid
  end

end
