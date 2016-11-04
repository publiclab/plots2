require 'test_helper'

# Test the get/post actions for the search forms
class SearchFlowTest < ActionDispatch::IntegrationTest

  test "advanced search basic test" do
    # "key_words"=>"post", "main_type"=>"Notes or Wiki updates", "language"=>"", "min_date"=>"", "max_date"=>""
    
    # Perform a URL GET search with a search term
    get '/search/map'
    assert_response :success

    # Perform a URL GET search without a term
    get '/search'
    assert_response :success

    # Perform a POST search submission without a term
    post '/search', 
         key_words: "blog",
         main_type: "Notes or Wiki updates"

    assert_response :success
 
    #  Perform a GET search call to advanced without a search term
    get '/search/advanced'
    assert_response :success

    post '/search',
         "search_record" => {
           key_words: 'post', 
           main_type: 'Notes or Wiki updates'
         }

    assert_response :success

    # https://publiclab.org/searches?key_words=spec

    post '/search',
         key_words: 'spectrom'

    assert_response :success

  end

end
