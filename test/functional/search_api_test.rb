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
      items: [{
        docUrl: "/notes/jeff/05-10-2017/blog-post",
        docTitle: "Blog post"
      }],
      srchParams: {
        srchString: 'Blog',
        seq: false,
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)
    
    assert matcher =~ JSON.parse(last_response.body)

  end

end
