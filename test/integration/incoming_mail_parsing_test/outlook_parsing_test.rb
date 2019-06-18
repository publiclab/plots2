require 'test_helper'
class OutlookParsingTest < ActionDispatch::IntegrationTest
  test 'should parse incoming mail from outlook service correctly and add comment reply' do
    require 'mail'
    mail = Mail.read('test/fixtures/incoming_test_emails/outlook/incoming_outlook_email.eml')
    comment = comments(:first)
    mail.subject = "Re: (##{comment.nid})"
    Comment.receive_mail(mail)
    f = File.open('test/fixtures/incoming_test_emails/outlook/final_parsed_comment.txt', 'r')
    reply = Comment.last
    user_email = mail.from.first
    assert_equal reply.comment, f.read
    assert_equal reply.reply_to, comment.id
    assert_equal reply.message_id, mail.message_id
    assert_equal reply.comment_via, 1
    assert_equal User.find(reply.uid).email, user_email
    f.close()
  end
end
