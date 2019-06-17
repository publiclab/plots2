require 'test_helper'
class GmailParsingTest < ActionDispatch::IntegrationTest
  test 'should parse incoming mail from gmail service correctly and add answer comment' do
    require 'mail'
    mail = Mail.read('test/fixtures/incoming_test_emails/gmail/incoming_gmail_email.eml')
    node = Node.find(21) # this is the nid used in the .eml fixture
    mail.subject = "Re: (##{node.id})"
    Comment.receive_mail(mail)
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
end
