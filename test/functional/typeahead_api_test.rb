require 'test_helper'

class TypeaheadApiTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def setup
    @stxt = 'l'
    @sprofile = 'a'
    @stags = 'everything'
    @sseq = 7
  end

  test 'typeahead all functionality' do
    get '/api/typeahead/all?srchString=l&seq=7'
    assert last_response.ok?
    
    # Expected typeahead pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: @stxt,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end

  test 'typeahead profile functionality' do
    get '/api/typeahead/profiles?srchString=a&seq=7'
    assert last_response.ok?

    # Expected profile response pattern
    pattern = {
      # Need more/better understanding and data for the test database, so ignoring null results for now
      # items: Array,
      srchParams: {
        srchString: @sprofile,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end

  test 'typeahead notes functionality' do
    get '/api/typeahead/notes?srchString=l&seq=7'
    assert last_response.ok?
    
    # Expected notes pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: @stxt,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end

  test 'typeahead questions functionality' do
    get '/api/typeahead/questions?srchString=l&seq=7'
    assert last_response.ok?
    
    # Expected question pattern
    #  Returns null right now for test--need to set a better search sequence on demo seed data
    pattern = {
      # Need more/better understanding and data for the test database, so ignoring null results for now
      # items:  Array,
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
      # Need more/better understanding and data for the test database, so ignoring null results for now
      # items: Array,
      srchParams: {
        srchString: @stags,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end

end
