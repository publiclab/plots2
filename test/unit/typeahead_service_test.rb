require 'test_helper'

class TypeaheadServiceTest < ActiveSupport::TestCase
  include SolrToggle
  
  test 'running TypeaheadService.notes with no Solr' do
    result = TypeaheadService.new.notes('blog')
    assert_false solrAvailable
    assert_not_nil result
    assert_equal result.length, 2
  end

end
