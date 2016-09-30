require 'test_helper'

class SearchFlowTest < ActionDispatch::IntegrationTest

  test "advanced search basic test" do
    # "key_words"=>"post", "main_type"=>"Notes or Wiki updates", "language"=>"", "min_date"=>"", "max_date"=>""

    get '/searches/new'

    assert_response :success

    post '/searches', 
         key_words: "blog",
         main_type: "Notes or Wiki updates"

    assert_response :success

    get '/searches/new'

    assert_response :success

  end

end
