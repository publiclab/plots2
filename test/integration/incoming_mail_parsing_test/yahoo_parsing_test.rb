require 'test_helper'
class YahooParsingTest < ActionDispatch::IntegrationTest

  test 'should parse incoming mail from yahoo service correctly and add answer comment' do
    require 'mail'
    mail = Mail.read('test/fixtures/incoming_test_emails/yahoo/incoming_yahoo_email.eml')
    # Mail contain ["01namangupta@gmail.com"] in from field.
    node = Node.find(21) # this is the nid used in the .eml fixture
    mail.subject = "Re: (##{node.id})"
    Comment.receive_mail(mail)
    f = File.open('test/fixtures/incoming_test_emails/yahoo/final_parsed_comment.txt', 'r')
    comment = Comment.last # this should be the just-created comment
    user_email = mail.from.first
    assert_equal comment.comment, f.read
    assert_equal comment.nid, node.id
    assert_equal comment.message_id, mail.message_id
    assert_equal comment.comment_via, 1
    assert_equal User.find(comment.uid).email, user_email
    f.close()
  end
end
