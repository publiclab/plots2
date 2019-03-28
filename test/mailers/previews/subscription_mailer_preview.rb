class SubscriptionMailerPreview < ActionMailer::Preview
  def send_digest
    SubscriptionMailer.send_digest(User.first.id, Node.last(2))
  end
end