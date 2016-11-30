class SubscriptionMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "do-not-reply@#{ActionMailer::Base.default_url_options[:host]}"

  def notify_node_creation(node)
    subject = "[PublicLab] " + (node.has_power_tag('question') ? "Question: " : "") +
              node.title
    DrupalTag.subscribers(node.tags).each do |key,val|
      @user = val[:user]
      @node = node
      @tags = val[:tags]
      @footer = feature('email-footer')
      mail(:to => val[:user].email, :subject => subject).deliver
    end
  end

  def notify_note_liked(node, user)
    subject = "[PublicLab] #{user.username} liked your " +
              (node.has_power_tag('question') ? "question" : "research note")
    @user = user
    @node = node
    mail(:to => node.author.email, :subject => subject).deliver
  end

end
