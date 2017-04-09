require 'test_helper'

# TODO:  Rework to get better inclusion of JsonExpressions pattern matching
# TODO:  Add tests for negative matches--check echo of search parameters and null result
# HACK:  Parameterize the 'get' URLs to make passing and changing test values easier

class TypeaheadApiTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def setup
    @stxt = 'lat'
    @sprofile = 'adm'
    @stags = 'everything'
    @sseq = 7
  end

  test 'typeahead all functionality' do
    get '/api/typeahead/all?srchString=lat&seq=7'
    assert last_response.ok?

    # Expected typeahead pattern
    pattern = {
      # TODO:  Need more/better understanding and data for the test database
      # return will be nil for now
      # items: nil,
      srchParams: {
        srchString: @stxt,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end

  test 'typeahead profile functionality' do
    get '/api/typeahead/profiles?srchString=adm&seq=7'
    assert last_response.ok?

    # Expected profile response pattern
    pattern = {
      # TODO:  Need more/better understanding and data for the test database
      # return will be nil for now
      # items: nil,
      srchParams: {
        srchString: @sprofile,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end

  test 'typeahead notes functionality' do
    get '/api/typeahead/notes?srchString=lat&seq=7'
    assert last_response.ok?

    # Expected notes pattern
    pattern = {
      # TODO:  Need more/better understanding and data for the test database
      # return will be nil for now
      # items: nil,
      srchParams: {
        srchString: @stxt,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end

  test 'typeahead questions functionality' do
    get '/api/typeahead/questions?srchString=lat&seq=7'
    assert last_response.ok?

    # Expected question pattern
    #  Returns null right now for test--need to set a better search sequence on demo seed data
    pattern = {
      # TODO:  Need more/better understanding and data for the test database
      # return will be nil for now
      # items: nil,
      srchParams: {
        srchString: @stxt,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end

  test 'typeahead tags functionality' do
    get '/api/typeahead/tags?srchString=everything&seq=7'
    assert last_response.ok?

    # Expected tag pattern
    pattern = {
      # TODO:  Need more/better understanding and data for the test database
      # return will be nil for now
      # items: nil,
      srchParams: {
        srchString: @stags,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end
end
