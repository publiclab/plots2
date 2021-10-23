require 'test_helper'
require 'mail'

class OutlookParsingTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  test 'should parse incoming mail from outlook service correctly and add comment reply' do
    mail = Mail.read('test/fixtures/incoming_test_emails/outlook/incoming_outlook_email.eml')
    comment = comments(:first)
    mail.subject = "Re: (##{comment.nid}) - #c#{comment.id}"
    Comment.new_comment_from_email(mail)
    f = File.open('test/fixtures/incoming_test_emails/outlook/final_parsed_comment.txt', 'r')
    reply = Comment.last
    user_email = mail.from.first
    assert_equal reply.comment, f.read
    assert_equal reply.message_id, mail.message_id
    assert_equal reply.comment_via, 1
    assert_equal reply.reply_to, comment.id
    assert_equal User.find(reply.uid).email, user_email
    f.close()
  end

  test 'recognizing autoreply mail from outlook service' do
    mail = Mail.read('test/fixtures/incoming_test_emails/outlook/autoreply_incoming_outlook_email.eml')
    assert_equal true, Comment.is_autoreply(mail)
  end

  test 'recognizing non-autoreply mail from outlook service' do
    mail = Mail.read('test/fixtures/incoming_test_emails/outlook/incoming_outlook_email.eml')
    assert_equal false, Comment.is_autoreply(mail)
  end
end
