class PasswordResetMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "do-not-reply@#{ActionMailer::Base.default_url_options[:host]}"

  # PasswordResetMailer.reset_notify(user).deliver
  def reset_notify(user, key)
    subject = '[Public Lab] Reset your password'
    @user = user
    @key = key
    @footer = feature('email-footer')
    mail(to: user.email, subject: subject).deliver
  end
end
