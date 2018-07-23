require 'test_helper'

class TypeaheadApiTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  test 'typeahead all functionality' do
    get '/api/typeahead/all?srchString=Blog'
    assert last_response.ok?

    # Expected typeahead pattern
    pattern = {
      srchParams: {
        srchString: 'Blog',
        seq: nil
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert matcher =~ json
  end

  test 'typeahead profile functionality' do
    get '/api/typeahead/profiles?srchString=Jeff'
    assert last_response.ok?

    # Expected profile response pattern
    pattern = {
      srchParams: {
        srchString: 'Jeff',
        seq: nil
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert matcher =~ json
  end

  test 'typeahead notes functionality' do
    get '/api/typeahead/notes?srchString=Blog'
    assert last_response.ok?

    # Expected notes pattern
    pattern = {
      srchParams: {
        srchString: 'Blog',
        seq: nil
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert matcher =~ json
  end

  test 'typeahead questions functionality' do
    get '/api/typeahead/questions?srchString=Question'
    assert last_response.ok?

    # Expected question pattern
    pattern = {
      srchParams: {
        srchString: 'Question',
        seq: nil,
       }.ignore_extra_keys!
     }.ignore_extra_keys!

     matcher = JsonExpressions::Matcher.new(pattern)

     json = JSON.parse(last_response.body)

     assert matcher =~ json
  end

  test 'typeahead tags functionality' do
    get '/api/typeahead/tags?srchString=everything'
    assert last_response.ok?

    # Expected tag pattern
    pattern = {
      srchParams: {
        srchString: 'everything',
        seq: nil
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert matcher =~ json
  end

  test 'typeahead comments functionality' do
    get '/api/typeahead/comments?srchString=comment'
    assert last_response.ok?

    # Expected comment pattern
    pattern = {
      srchParams: {
        srchString: 'comment',
        seq: nil
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    json = JSON.parse(last_response.body)

    assert matcher =~ json
  end
end
