require 'test_helper'

class TypeaheadServiceTest < ActiveSupport::TestCase
  include SolrToggle
  
  test 'running TypeaheadService.new.notes with no Solr' do
    result = TypeaheadService.new.notes('blog')
    assert_not solrAvailable
    assert_not_nil result
    assert_equal 1, result.length
  end

  test 'running TypeaheadService.new.users with no Solr' do
    result = TypeaheadService.new.users('obiwan')
    assert_not solrAvailable
    assert_not_nil result
    assert_equal 1, result.length
  end

end
