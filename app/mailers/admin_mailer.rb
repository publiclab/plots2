# frozen_string_literal: true

class AdminMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "notifications@#{ActionMailer::Base.default_url_options[:host]}"

  def notify_node_moderators(node)
    subject = '[New Public Lab poster needs moderation] ' + node.title
    @node = node
    @user = node.author
    @footer = feature('email-footer')
    all_moderators = User.where(role: %w(moderator admin))
    moderators = []
    all_moderators.each do |mod_user|
      moderators << mod_user.email unless mod_user.has_tag('no-moderation-emails')
    end
    if node.status == 4 # only if it remains unmoderated
      mail(
        to: "moderators@#{ActionMailer::Base.default_url_options[:host]}",
        bcc: moderators,
        subject: subject
      )
    end
  end

  def notify_comment_moderators(comment)
    subject = '[New Public Lab poster needs moderation]'
    @comment = comment
    @user = comment.author
    @footer = feature('email-footer')
    moderators = User.where(role: %w(moderator admin)).collect(&:email)
    if comment.status == 4 # only if it remains unmoderated
      mail(
        to: "comment-moderators@#{ActionMailer::Base.default_url_options[:host]}",
        bcc: moderators,
        subject: subject
      )
    end
  end

  def notify_author_of_approval(node, moderator)
    subject = '[Public Lab] Your post was approved!'
    @author = node.author
    @moderator = moderator
    @node = node
    @footer = feature('email-footer')
    mail(to: @author.email, subject: subject)
  end

  def notify_author_of_comment_approval(comment, moderator)
    subject = '[Public Lab] Your comment was approved!'
    @author_mail = comment.author.email
    @moderator = moderator
    @comment = comment
    @footer = feature('email-footer')
    mail(to: @author_mail, subject: subject)
  end

  # Will this further bait spammers? If we don't,
  # will non-spammers whose posts were moderated get confused?
  # Should: show explanation/appeal process to authors who visit again
  # Should: prompt moderators to reach out if it's not spam, but a guidelines
  # violation
  # def notify_author_of_spam(node)
  # end

  def notify_moderators_of_comment_spam(comment, moderator)
    subject = '[New Public Lab comment needs moderation]'
    @author = comment.author
    @moderator = moderator
    @comment = comment
    @footer = feature('email-footer')
    moderators = User.where(role: %w(moderator admin)).collect(&:email)
    mail(
      to: "comment-moderators@#{ActionMailer::Base.default_url_options[:host]}",
      bcc: moderators,
      subject: subject
    )
  end

  def notify_moderators_of_approval(node, moderator)
    subject = '[New Public Lab poster needs moderation] ' + node.title
    @author = node.author
    @moderator = moderator
    @node = node
    @footer = feature('email-footer')
    moderators = User.where(role: %w(moderator admin)).collect(&:email)
    mail(
      to: "moderators@#{ActionMailer::Base.default_url_options[:host]}",
      bcc: moderators,
      subject: subject
    )
  end

  def notify_moderators_of_comment_approval(comment, moderator)
    subject = '[New Public Lab commenter needs moderation]'
    @author = comment.author
    @moderator = moderator
    @comment = comment
    @footer = feature('email-footer')
    moderators = User.where(role: %w(moderator admin)).collect(&:email)
    mail(
      to: "comment-moderators@#{ActionMailer::Base.default_url_options[:host]}",
      bcc: moderators,
      subject: subject
    )
  end

  def notify_moderators_of_spam(node, moderator)
    subject = '[New Public Lab poster needs moderation] ' + node.title
    @author = node.author
    @moderator = moderator
    @node = node
    @footer = feature('email-footer')
    moderators = User.where(role: %w(moderator admin)).collect(&:email)
    mail(
      to: "moderators@#{ActionMailer::Base.default_url_options[:host]}",
      bcc: moderators,
      subject: subject
    )
  end

  def send_digest_spam(nodes, frequency_digest)
    if frequency_digest == User::Frequency::DAILY
      @subject = 'Your daily digest for moderation'
    elsif frequency_digest == User::Frequency::WEEKLY
      @subject = 'Your weekly digest for moderation'
    end
    moderators = User.where(role: %w(moderator admin)).collect(&:email)
    @nodes = nodes
    mail(
      to: "moderators@#{ActionMailer::Base.default_url_options[:host]}",
      bcc: moderators,
      subject: @subject
    )
  end
end
