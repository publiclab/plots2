require 'test_helper'

class TypeaheadServiceTest < ActiveSupport::TestCase
  include SolrToggle
  
  test 'running TypeaheadService.notes' do
    assert_false solrAvailable
    result = TypeaheadService.new.notes('blog')
puts result.inspect
    assert_not_nil result
    assert_equal result.length, 2
  end

end

# Need to be tested:

#  def users(input, limit = 5)
#  def tags(input, limit = 5)
#  def comments(input, limit = 5)
#  def wikis(input, limit = 5)
#  def maps(input, limit = 5)
#  def all_results(srchString, limit = 5)
#  def search_profiles(srchString, limit = 5)
#  def search_maps(srchString, limit = 5)
#  def search_tags(srchString, limit = 5)
#  def search_questions(srchString, limit = 5)
