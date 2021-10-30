# frozen_string_literal: true

class CommentMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "notifications@#{ActionMailer::Base.default_url_options[:host]}"

  # CommentMailer.notify_of_comment(user,self).deliver_now
  def notify(user, comment)
    @user = user
    @comment = comment
    @footer = feature('email-footer')
    mail(to: user.email, subject: "New comment on #{comment.node.title}" \
                                  " (##{comment.node.id}) - #c#{comment.id} ")
  end

  def notify_note_author(user, comment)
    @user = user
    @comment = comment
    @footer = feature('email-footer')
    mail(to: user.email, subject: "New comment on #{comment.node.title}" \
                                  " (##{comment.node.id}) - #c#{comment.id}")
  end

  # user is awarder, not awardee
  def notify_barnstar(user, note)
    @giver = user
    @note = note
    @footer = feature('email-footer')
    mail(to: note.author.email, subject: 'You were awarded a Barnstar!')
  end

  def notify_callout(comment, user)
    @user = user
    @comment = comment
    @footer = feature('email-footer')
    mail(to: user.email, subject: 'You were mentioned in a comment.' \
                                  " (##{comment.node.id}) - #c#{comment.id} ")
  end

  def notify_tag_followers(comment, user)
    @user = user
    @comment = comment
    @footer = feature('email-footer')
    mail(to: user.email, subject: 'A tag you follow was mentioned in ' \
                                  'a comment.' \
                                  " (##{comment.node.id}) - #c#{comment.id} ")
  end

  def notify_coauthor(user, note)
    @user = user
    @note = note
    @author = note.author
    @footer = feature('email-footer')
    mail(to: user.email, subject: 'You were added as a co-author!')
  end
end
