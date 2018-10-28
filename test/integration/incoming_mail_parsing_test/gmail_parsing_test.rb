require 'test_helper'
class GmailParsingTest < ActionDispatch::IntegrationTest
  test 'should parse incoming mail from gmail service correctly and add answer comment' do
    require 'mail'
    mail = Mail.read('test/fixtures/incoming_test_emails/gmail/incoming_gmail_email.eml')
    answer = Answer.last
    mail.subject = "Re: (#a#{answer.id})"
    Comment.receive_mail(mail)
    f = File.open('test/fixtures/incoming_test_emails/gmail/final_parsed_comment.txt', 'r')
    comment = Comment.last
    user_email = mail.from.first
    assert_equal comment.comment, f.read
    assert_equal comment.aid, answer.id
    assert_equal comment.message_id, mail.message_id
    assert_equal comment.comment_via, 1
    assert_equal User.find(comment.uid).email, user_email
    f.close()
  end
end
