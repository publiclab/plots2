class AdminMailer < ActionMailer::Base
  default from: "moderators@publiclab.org"

  def notify_node_moderators(node)
    subject = "[New Public Lab poster needs moderation] " + node.title
    @node = node
    moderators = User.where(role: ['moderator', 'admin']).collect(&:email)
    mail(
      to: "moderators@publiclab.org", 
      bcc: moderators, 
      subject: subject
    ).deliver
  end

  def notify_author_of_approval(node, moderator)
    subject = "[Public Lab] Your post was approved!"
    @author = node.author
    @moderator = moderator
    @node = node
    mail(:to => @author.mail, :subject => subject).deliver
  end

  # Will this further bait spammers? If we don't, 
  # will non-spammers whose posts were moderated get confused?
  # Should: show explanation/appeal process to authors who visit again
  # Should: prompt moderators to reach out if it's not spam, but a guidelines violation
  #def notify_author_of_spam(node)
  #end

  def notify_moderators_of_approval(node, moderator)
    subject = "[New Public Lab poster needs moderation] " + node.title
    @author = node.author
    @moderator = moderator
    @node = node
    moderators = User.where(role: ['moderator', 'admin']).collect(&:email)
    mail(
      to: "moderators@publiclab.org", 
      bcc: moderators, 
      subject: subject
    ).deliver
  end

  def notify_moderators_of_spam(node, moderator)
    subject = "[New Public Lab poster needs moderation] " + node.title
    @author = node.author
    @moderator = moderator
    @node = node
    moderators = User.where(role: ['moderator', 'admin']).collect(&:email)
    mail(
      to: "moderators@publiclab.org", 
      bcc: moderators, 
      subject: subject
    ).deliver
  end

end
