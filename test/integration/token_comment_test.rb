require 'test_helper'

class TokenCommentTest < ActionDispatch::IntegrationTest
  test 'should not post comment through invalid token successfully' do
    post '/comment/create/token/1.json', params: { body: 'Test Comment', username: 'Bob' }, headers: { 'HTTP_TOKEN' => 'invalid-token' }
    assert_response :unauthorized
  end

  test 'should not post an invalid comment successfully' do
    post '/comment/create/token/1.json', params: { body: '', username: 'Bob' }, headers: { 'HTTP_TOKEN' => 'abcdefg12345' }
    assert_response :bad_request
  end

  test 'should post comment through valid token successfully' do
    post '/comment/create/token/1.json', params: { body: 'Test Comment', username: 'Bob' }, headers: { 'HTTP_TOKEN' => 'abcdefg12345' }
    assert_response :success
  end
  
    test 'should parse incoming mail from other domain who use gmail service correctly and add comment' do
    require 'mail'
    mail = Mail.read('test/fixtures/incoming_test_emails/gmail/incoming_gmail_email.eml')
    node = Node.last
    mail.subject = "Re: #{node.title} (##{node.nid})"
    mail.from = ["jeff@publiclab.org"]
    Comment.receive_mail(mail)
    f = File.open('test/fixtures/incoming_test_emails/gmail/final_parsed_comment.txt', 'r')
    comment = Comment.last
    assert_equal comment.comment, f.read
    assert_equal comment.nid, node.id
    assert_equal comment.message_id, mail.message_id
    assert_equal comment.comment_via, 1
    assert_equal User.find(comment.uid).email, "jeff@publiclab.org"
    f.close()
  end
  
   test 'should parse incoming mail from yahoo service correctly and add comment' do
    require 'mail'
    mail = Mail.read('test/fixtures/incoming_test_emails/yahoo/incoming_yahoo_email.eml')
    node = Node.last
    mail.subject = "Re: #{node.title} (##{node.nid})"
    Comment.receive_mail(mail)
    f = File.open('test/fixtures/incoming_test_emails/yahoo/final_parsed_comment.txt', 'r')
    comment = Comment.last
    user_email = mail.from.first
    assert_equal comment.comment, f.read
    assert_equal comment.nid, node.id
    assert_equal comment.message_id, mail.message_id
    assert_equal comment.comment_via, 1
    assert_equal User.find(comment.uid).email, user_email
    f.close()
  end
end
