class WelcomeMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "Public Lab <notifications@#{ActionMailer::Base.default_url_options[:host]}>"

  # PasswordResetMailer.reset_notify(user).deliver_now
  def add_to_list(user, list)
    subject = 'subscribe'
    @list = list
    @footer = feature('email-footer')
    mail(to: list + '+subscribe@googlegroups.com', subject: subject, from: user.email)
  end

  def notify_newcomer(user)
    subject = 'Welcome to Public Lab'
    @user = user
    @footer = feature('email-footer')
    @body = feature_node('welcome-email-body')
    mail(to: user.email, subject: subject)
  end
end
