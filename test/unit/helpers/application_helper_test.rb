require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  test 'should give filtered comment body' do
    f = File.open('test/fixtures/incoming_test_emails/gmail/final_parsed_comment.txt', 'r')
    filtered_body = filtered_comment_body(f.read)
    f.close()
    f = File.open('test/fixtures/incoming_test_emails/gmail/filtered_comment.txt', 'r')
    assert_equal filtered_body, f.read
    f.close()
  end

  test 'should give trimmed content of comment' do
    f = File.open('test/fixtures/incoming_test_emails/gmail/final_parsed_comment.txt', 'r')
    trimmed_content = trimmed_body(f.read)
    f.close()
    f = File.open('test/fixtures/incoming_test_emails/gmail/trimmed_content.txt', 'r')
    assert_equal trimmed_content, f.read
    f.close()
  end

  test 'should return true if contain trimmed content' do
    f = File.open('test/fixtures/incoming_test_emails/gmail/final_parsed_comment.txt', 'r')
    contain_trimmed_body = contain_trimmed_body?(f.read)
    assert_equal contain_trimmed_body, true
    f.close()
  end

  test 'should return false if there is no trimmed content' do
    contain_trimmed_body = contain_trimmed_body?("Without trimmed content")
    assert_equal contain_trimmed_body, false
  end

end
