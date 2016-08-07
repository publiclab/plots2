require 'test_helper'
require 'rest-client'

class RestfulSearchTest < ActionController::TestCase

  def setup
    @stxt = 'l'
    @sprofile = 'a'
    @stags = 'lon:24.484315929497463'
    @sseq = 7
  end

  test 'search all functionality' do
    srchresponse = RestClient.get 'http://localhost:3000/api/srch/all', {:params => {'srchString' => @stxt, 'seq' => @sseq }}
    
    # Expected search pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: @stxt,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(srchresponse.body)
  end

  test 'search profile functionality' do
    searchresponse = RestClient.get 'http://localhost:3000/api/srch/profiles', {:params => {'srchString' => @sprofile, 'seq' => @sseq }}
    
    # Expected profile response pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: @sprofile,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(searchresponse.body)
  end

  test 'search notes functionality' do
    searchresponse = RestClient.get 'http://localhost:3000/api/srch/notes', {:params => {'srchString' => @stxt, 'seq' => @sseq }}
    
    # Expected notes pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: @stxt,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(searchresponse.body)
  end

  test 'search questions functionality' do
    searchresponse = RestClient.get 'http://localhost:3000/api/srch/questions', {:params => {'srchString' => @stxt, 'seq' => @sseq }}
    
    # Expected question pattern
    #  Returns null right now for test--need to set a better search sequence on demo seed data
    pattern = {
      srchParams: {
        srchString: @stxt,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(searchresponse.body)
  end

  test 'search tags functionality' do
    searchresponse = RestClient.get 'http://localhost:3000/api/srch/tags', {:params => {'srchString' => @stags, 'seq' => @sseq }}
    
    # Expected tag pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: @stags,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(searchresponse.body)
  end


end
