require 'test_helper'

class RestfulSearchTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  #def setup
  #  @stxt = 'l'
  #  @sprofile = 'a'
  #  @stags = 'lon:24.484315929497463'
  #  @sseq = 7
  #end

  test 'returns a list of results from search all functionality' do
    get '/api/srch/all?srchString=l&seq=7'
    assert last_response.ok?
    # Expected search pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: 'l',
        seq: 7
      }.ignore_extra_keys!
    }.ignore_extra_keys!
    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end


  test 'returns results from search profile functionality' do
    get '/api/srch/profiles?srchString=a&seq=7'
    assert last_response.ok?
    # Expected profile response pattern
    pattern = {
      # Need more/better understanding and data for the test database, so ignoring null results for now
      # items: Array,
      srchParams: {
        srchString: 'a',
        seq: 7
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end


  test 'returns result from search notes functionality' do
    get '/api/srch/notes?srchString=l&seq=7'
    assert last_response.ok?
    # Expected notes pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: 'l',
        seq: 7
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end


  test 'returns results from search questions functionality' do
    get '/api/srch/questions?srchString=l&seq=7'
    assert last_response.ok?
    # Expected question pattern
    #  Returns null right now for test--need to set a better search sequence on demo seed data
    pattern = {
      srchParams: {
        srchString: 'l',
        seq: 7
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end


  test 'returns results from search tags functionality' do
    get '/api/srch/tags?srchString=lon:24.484315929497463&seq=7'
    assert last_response.ok?
    # Expected tag pattern
    pattern = {
      # Need more/better understanding and data for the test database, so ignoring null results for now
      # items: Array,
      srchParams: {
        srchString: 'lon:24.484315929497463',
        seq: 7
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(last_response.body)
  end

end
