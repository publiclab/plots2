class AdminMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "do-not-reply@#{ActionMailer::Base.default_url_options[:host]}"

  def notify_node_moderators(node1)
    subject = "[New Public Lab poster needs moderation] " + node1.title
    @node = node1
    @footer = feature('email-footer')
    moderators = User.where(role: ['moderator', 'admin']).collect(&:email)
    mail(
      to: "moderators@#{ActionMailer::Base.default_url_options[:host]}", 
      bcc: moderators, 
      subject: subject
    ).deliver
  end

  def notify_author_of_approval(node1, moderator)
    subject = "[Public Lab] Your post was approved!"
    @author = node1.author
    @moderator = moderator
    @node = node1
    @footer = feature('email-footer')
    mail(:to => @author.mail, :subject => subject).deliver
  end

  # Will this further bait spammers? If we don't, 
  # will non-spammers whose posts were moderated get confused?
  # Should: show explanation/appeal process to authors who visit again
  # Should: prompt moderators to reach out if it's not spam, but a guidelines violation
  #def notify_author_of_spam(node)
  #end

  def notify_moderators_of_approval(node1, moderator)
    subject = "[New Public Lab poster needs moderation] " + node1.title
    @author = node1.author
    @moderator = moderator
    @node = node1
    @footer = feature('email-footer')
    moderators = User.where(role: ['moderator', 'admin']).collect(&:email)
    mail(
      to: "moderators@#{ActionMailer::Base.default_url_options[:host]}", 
      bcc: moderators, 
      subject: subject
    ).deliver
  end

  def notify_moderators_of_spam(node1, moderator)
    subject = "[New Public Lab poster needs moderation] " + node1.title
    @author = node1.author
    @moderator = moderator
    @node = node1
    @footer = feature('email-footer')
    moderators = User.where(role: ['moderator', 'admin']).collect(&:email)
    mail(
      to: "moderators@#{ActionMailer::Base.default_url_options[:host]}", 
      bcc: moderators, 
      subject: subject
    ).deliver
  end

end
