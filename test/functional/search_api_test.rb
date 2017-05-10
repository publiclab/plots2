require 'test_helper'

class SearchApiTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  test 'search notes functionality' do
    get '/api/srch/notes?srchString=Blog'
    assert last_response.ok?

    # Expected search pattern
    pattern = {
      srchParams: {
        srchString: 'Blog',
        seq: false,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    puts JSON.parse(last_response.body)
    assert matcher =~ JSON.parse(last_response.body)
    

    # check for actual Blog note, too
    # assert_equal ___, node(:blog)
    
    
    

  end

end
