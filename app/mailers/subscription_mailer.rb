class SubscriptionMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "do-not-reply@#{ActionMailer::Base.default_url_options[:host]}"

  def notify_node_creation(node1)
    subject = "[PublicLab] " + (node1.has_power_tag('question') ? "Question: " : "") +
              node1.title
    Tag.subscribers(node1.tags).each do |key,val|
      @user = val[:user]
      @node = node1
      @tags = val[:tags]
      @footer = feature('email-footer')
      mail(:to => val[:user].email, :subject => subject).deliver
    end
  end

  def notify_note_liked(node1, user)
    subject = "[PublicLab] #{user.username} liked your " +
              (node1.has_power_tag('question') ? "question" : "research note")
    @user = user
    @node = node1
    @footer = feature('email-footer')
    mail(:to => node1.author.email, :subject => subject).deliver
  end

end
