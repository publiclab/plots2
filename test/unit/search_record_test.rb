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

  test "DrupalNode.search" do
    solr_search = DrupalNode.search do
      fulltext 'spectro'
      with(:updated_at).less_than(Time.zone.now)
      facet(:updated_month)
      with(:updated_month, month) if month.present?
      #paginate :page => 1, :per_page => 10
    end
  end

end
