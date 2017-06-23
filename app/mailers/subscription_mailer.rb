class SubscriptionMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "do-not-reply@#{ActionMailer::Base.default_url_options[:host]}"

  def notify_node_creation(node)
    subject = '[PublicLab] ' + (node.has_power_tag('question') ? 'Question: ' : '') +
              node.title
    Tag.subscribers(node.tags).each do |_key, val|
      @user = val[:user]
      @node = node
      @tags = val[:tags]
      @footer = feature('email-footer')
      mail(to: val[:user].email, subject: subject).deliver
    end
  end

  def notify_note_liked(node, user)
    subject = "[PublicLab] #{user.username} liked your " +
              (node.has_power_tag('question') ? 'question' : 'research note')
    @user = user
    @node = node
    @footer = feature('email-footer')
    mail(to: node.author.email, subject: subject).deliver
  end

  def notify_tag_added(node,tag)
    given_tags = node.subscriptions
    users_to_email = tag.followers_who_dont_follow_tags(given_tags)
    users_to_email.each do |user|
      @user = user
      mail(to: user, subject: "New tag added on #{node.title}").deliver
    end
    @footer = feature('email-footer')
  end
end
