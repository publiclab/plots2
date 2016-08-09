require 'test_helper'
require 'rest-client'

class TypeaheadApiTest < ActionController::TestCase

  def setup
    @stxt = 'l'
    @sprofile = 'a'
    @stags = 'lon:24.484315929497463'
    @sseq = 7
  end

  test 'typeahead all functionality' do
    typeresponse = RestClient.get 'http://localhost:3000/api/typeahead/all', {:params => {'srchString' => @stxt, 'seq' => @sseq }}
    
    # Expected typeahead pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: @stxt,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(typeresponse.body)
  end

  test 'typeahead profile functionality' do
    typeresponse = RestClient.get 'http://localhost:3000/api/typeahead/profiles', {:params => {'srchString' => @sprofile, 'seq' => @sseq }}
    
    # Expected profile response pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: @sprofile,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(typeresponse.body)
  end

  test 'typeahead notes functionality' do
    typeresponse = RestClient.get 'http://localhost:3000/api/typeahead/notes', {:params => {'srchString' => @stxt, 'seq' => @sseq }}
    
    # Expected notes pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: @stxt,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(typeresponse.body)
  end

  test 'typeahead questions functionality' do
    typeresponse = RestClient.get 'http://localhost:3000/api/typeahead/questions', {:params => {'srchString' => @stxt, 'seq' => @sseq }}
    
    # Expected question pattern
    #  Returns null right now for test--need to set a better search sequence on demo seed data
    pattern = {
      srchParams: {
        srchString: @stxt,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(typeresponse.body)
  end

  test 'typeahead tags functionality' do
    typeresponse = RestClient.get 'http://localhost:3000/api/typeahead/tags', {:params => {'srchString' => @stags, 'seq' => @sseq }}
    
    # Expected tag pattern
    pattern = {
      items: Array,
      srchParams: {
        srchString: @stags,
        seq: @sseq
      }.ignore_extra_keys!
    }.ignore_extra_keys!

    matcher = JsonExpressions::Matcher.new(pattern)

    assert matcher =~ JSON.parse(typeresponse.body)
  end


end
