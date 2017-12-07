require 'test_helper'

class TypeaheadServiceTest < ActiveSupport::TestCase
  include SolrToggle
  
  test 'running TypeaheadService.search_all' do
    result = TypeaheadService.new.search_all('about').getTags()
    assert solrAvailable
    assert_not_nil result
    assert_equal result.length, 2
    result = TypeaheadService.new.search_all('Canon').getTags() # searching for a node
    assert_not_nil result
    assert_equal 1, result.length
  end

  test 'running TypeaheadService.notes' do
    result = TypeaheadService.new.notes('blog')
    assert solrAvailable
    assert_not_nil result
    assert_equal 2, result.length
  end

end

# Need to be tested:

#  def drupal_users(input, limit = 5)
#  def tags(input, limit = 5)
#  def comments(input, limit = 5)
#  def wikis(input, limit = 5)
#  def maps(input, limit = 5)
#  def all_results(srchString, limit = 5)
#  def search_profiles(srchString, limit = 5)
#  def search_maps(srchString, limit = 5)
#  def search_tags(srchString, limit = 5)
#  def search_questions(srchString, limit = 5)
