require 'test_helper'

class SearchHelperTest < ActionView::TestCase

	test "search Recent People helper" do
		sservice = SearchService.new
		result = sservice.recentPeople(100)
		assert_equal result.items.first.docType , "people_coordinates"
		assert_equal result.items.first.docTitle , users(:bob).username
		assert_equal result.items.first.docSummary , 0
		assert_equal result.items.first.docScore , 0
		assert_equal result.items.first.latitude , "41"
		assert_equal result.items.first.longitude , "-90"
	end
end
