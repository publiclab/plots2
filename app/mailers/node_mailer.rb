# frozen_string_literal: true

class NodeMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "notifications@#{ActionMailer::Base.default_url_options[:host]}"

  def notify_callout(node, user)
    @user = user
    @node = node
    @footer = feature('email-footer')
    mail(to: user.email, subject: "(##{node.id}) You were mentioned in a note")
  end
end
