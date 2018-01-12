require 'test_helper'

class ConstantsTest < ActiveSupport::TestCase
  # This is used to test the constants at config/initializer
  test 'should not match backtick' do
    string = '@StlMaris123 @StlMaris123 `@StlMaris123`'
    expect = 'REPLACE REPLACE `@StlMaris123`'
    assert_equal expect, string.gsub(Callouts.const_get(:FINDER), ' REPLACE').lstrip!
  end

  test 'hashtag regex should not match initial hash' do
    string = '#tag'
    assert_no_match Callouts.const_get(:HASHTAG), string
  end

  test 'hashtag regex should match non-initial hash' do
    string = 'this is a #tag'
    assert_match Callouts.const_get(:HASHTAG), string
  end

  test 'hashtag regex should match colon' do
    string = 'this is a #colon:tag'
    assert string.scan(Callouts.const_get(:HASHTAG))[0][1] == 'colon:tag'
  end

  test 'hashtag regex should match multiple non-initial hash' do
    string = 'this is a #tag #anotheRTag, #question:spectrometer'
    assert string.scan(Callouts.const_get(:HASHTAG)).length == 3
  end

  test 'hashtagnumber regex should match non-initial hash' do 
    string = "hello #123 #hello " ;
    assert string.scan(Callouts.const_get(:HASHTAGNUMBER)).length == 1
    expect = "hello REPLACE #hello " ;
    assert_equal expect, string.gsub(Callouts.const_get(:HASHTAGNUMBER), ' REPLACE') ;
  end
end
