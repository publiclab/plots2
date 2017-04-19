class CommentMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "do-not-reply@#{ActionMailer::Base.default_url_options[:host]}"

  # CommentMailer.notify_of_comment(user,self).deliver
  def notify(user, comment)
    @user = user
    @comment = comment
    @footer = feature('email-footer')
    mail(to: user.email, subject: "New comment on '" + comment.parent.title + "'")
  end

  def notify_note_author(user, comment)
    @user = user
    @comment = comment
    @footer = feature('email-footer')
    mail(to: user.email, subject: "New comment on '" + comment.node.title + "'")
  end

  # user is awarder, not awardee
  def notify_barnstar(user, note)
    @giver = user.drupal_user
    @note = note
    @footer = feature('email-footer')
    mail(to: note.author.email, subject: 'You were awarded a Barnstar!').deliver
  end

  def notify_callout(comment, user)
    @user = user
    @comment = comment
    @footer = feature('email-footer')
    mail(to: user.email, subject: 'You were mentioned in a comment.').deliver
  end

  def notify_tag_followers(comment, user)
    @user = user
    @comment = comment
    @footer = feature('email-footer')
    mail(to: user.email, subject: 'A tag you follow was mentioned in a comment.').deliver
  end

  def notify_answer_author(user, comment)
    @user = user
    @comment = comment
    @footer = feature('email-footer')
    mail(to: user.email, subject: "New comment on your answer on '" + comment.parent.title + "'")
  end
end
