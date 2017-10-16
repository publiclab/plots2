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

  def notify_tag_added(node, tag, current_user)
    @tag = tag
    @node = node
    @current_user = current_user
    given_tags = node.tags.reject { |t| t == tag}
    users_to_email = tag.followers_who_dont_follow_tags(given_tags).pluck(:id)
    users_with_everything_tag = TagSelection.users_following_everything_tag.pluck(:user_id)
    final_users_ids = users_to_mail - users_with_everything_tag
    final_users_to_email = User.find(final_users_ids) 
    final_users_to_email.each do |user|
      @user = user
      unless user.id == current_user.id 
        mail(to: user.email, subject: "New tag added on #{node.title}").deliver 
      end
    end
    @footer = feature('email-footer')
  end
end
