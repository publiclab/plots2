class SubscriptionMailer < ActionMailer::Preview
  def notify_tag_added
  user = User.first
  SubscriptionMailer.notify_tag_added(user)
  end
config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
end

