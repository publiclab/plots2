# frozen_string_literal: true

class PasswordResetMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: 'Public Lab <notifications@' \
                "#{ActionMailer::Base.default_url_options[:host]}>"

  # PasswordResetMailer.reset_notify(user).deliver_now
  def reset_notify(user, key)
    subject = 'Reset your password'
    @user = user
    @key = key
    @footer = feature('email-footer')
    mail(to: user.email, subject: subject)
  end
end
