require 'test_helper'
class GmailParsingTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  test 'should parse incoming mail from gmail service correctly and add comment' do
    require 'mail'
    mail = Mail.read('test/fixtures/incoming_test_emails/gmail/incoming_gmail_email.eml')
    node = Node.find(21) # this is the nid used in the .eml fixture
    mail.subject = "Re: (##{node.id})"
    Comment.new_comment_from_email(mail)
    f = File.open('test/fixtures/incoming_test_emails/gmail/final_parsed_comment.txt', 'r')
    reply = Comment.last # this should be the just-created comment
    user_email = mail.from.first
    assert_equal reply.comment, f.read
    assert_equal reply.nid, node.id
    assert_equal reply.message_id, mail.message_id
    assert_equal reply.comment_via, 1 # meaning email
    assert_equal User.find(reply.uid).email, user_email
    f.close()
  end

  test 'recognizing autoreply mail from gmail service' do
    mail = Mail.read('test/fixtures/incoming_test_emails/gmail/autoreply_incoming_gmail_email.eml')
    assert_equal true, Comment.is_autoreply(mail)
  end

  test 'recognizing non-autoreply mail from gmail service' do
    mail = Mail.read('test/fixtures/incoming_test_emails/gmail/incoming_gmail_email.eml')
    assert_equal false, Comment.is_autoreply(mail)
  end

end
