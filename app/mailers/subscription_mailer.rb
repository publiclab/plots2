class SubscriptionMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "notifications@#{ActionMailer::Base.default_url_options[:host]}"

  def notify_node_creation(node)
    subject = '[PublicLab] ' + (node.has_power_tag('question') ? 'Question: ' : '') + node.title + " (##{node.id}) "
    @node = node
    @tags = node.tags.collect(&:name).join(',')
    @footer = feature('email-footer')
    recipients = Tag.subscribers(node.tags).values.map { |obj| obj[:user] }.collect(&:email)
    mail(
      to: "notifications@#{ActionMailer::Base.default_url_options[:host]}",
      bcc: recipients,
      subject: subject
    )
  end

  def notify_note_liked(node, user)
    subject = "[PublicLab] #{user.username} liked your " +
              (node.has_power_tag('question') ? 'question' : 'research note') +
              " (##{node.id})"
    @user = user
    @node = node
    @footer = feature('email-footer')
    mail(to: node.author.email, subject: subject)
  end

  def notify_tag_added(node, tag, tagging_user)
    @tag = tag
    @node = node
    @tagging_user = tagging_user
    given_tags = node.tags.reject { |t| t == tag }
    users_to_email = tag.followers_who_dont_follow_tags(given_tags)
    users_with_everything_tag = Tag.followers('everything')
    final_users_ids = nil
    if !users_to_email.nil? && !users_with_everything_tag.nil?
      final_users_ids = users_to_email.collect(&:id) - users_with_everything_tag.collect(&:uid)
    elsif !users_to_email.nil?
      final_users_ids = users_to_email.collect(&:id)
    end
    final_users_to_email = User.find(final_users_ids)
    recipients = []
    final_users_to_email.each do |user|
      unless user.id == tagging_user.id
        recipients << user.email
      end
    end
    @footer = feature('email-footer')
    mail(
      to: "notifications@#{ActionMailer::Base.default_url_options[:host]}",
      bcc: recipients,
      subject: "#{node.title} (##{node.id})"
    )
   end

  def send_digest(user_id, nodes, freq)
    if freq == 0
      @subject = "Your weekly digest"
    elsif freq == 1
      @subject = "Your daily digest"
    end
    @user = User.find(user_id)
    @nodes = nodes
    mail(to: @user.email, subject: @subject)
  end
end
