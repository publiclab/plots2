require 'test_helper'

class TypeaheadServiceTest < ActiveSupport::TestCase
  
  test 'running TypeaheadService.new.notes' do
    result = TypeaheadService.new.notes('blog')
    assert_not_nil result
    assert_equal 1, result.length
    assert_equal result.length, result.uniq.length
  end
  
#  test 'running TypeaheadService.new.wikis' do
#    assert_equal 1, Node.search('about').length # <= this fails but shouldn't; help!
#    result = TypeaheadService.new.wikis('about')
#    assert_not_nil result
#    assert_equal 1, result.length
#    assert_equal result.length, result.uniq.length
#  end
  
  test 'running TypeaheadService.new.tags and returning one result despite both `blog` and `blog-featured` tags' do
    result = TypeaheadService.new.tags('blog')
    assert_not_nil result
    assert_equal 1, result.length
    assert_equal result.length, result.uniq.length
  end

  test 'running TypeaheadService.new.users' do
    result = TypeaheadService.new.users('obiwan')
    assert_not_nil result
    assert_equal 1, result.length
  end

end
