require 'test_helper'

class TypeaheadServiceTest < ActiveSupport::TestCase
  include SolrToggle
  
  test 'running TypeaheadService.notes with no Solr' do
    result = TypeaheadService.new.notes('blog')
    assert_false solrAvailable
    assert_not_nil result
    assert_equal 1, result.length
  end
  
  test 'running TypeaheadService.notes with no Solr' do
    result = TypeaheadService.new.profiles('adm')
    assert_false solrAvailable
    assert_not_nil result
    assert_equal 1, result.length
  end

end
