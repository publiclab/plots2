class CommentMailer < ActionMailer::Base
  default from: "do-not-reply@publiclab.org"

  # CommentMailer.notify_of_comment(user,self).deliver 
  def notify(user,comment)
    @user = user
    @comment = comment
    mail(:to => user.email, :subject => "New comment on '"+comment.node.title+"'")
  end

  def notify_note_author(user,comment)
    @user = user
    @comment = comment
    mail(:to => user.email, :subject => "New comment on '"+comment.node.title+"'")
  end

  # user is awarder, not awardee
  def notify_barnstar(user,note)
    @giver = user.drupal_user
    @note = note
    mail(:to => user.email, :subject => "You were awarded a Barnstar!").deliver
  end

end
