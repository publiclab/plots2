class CommentMailer < ActionMailer::Base
  default from: "do-not-reply@publiclab.org"

  # CommentMailer.notify_of_comment(user,self).deliver 
  def notify(user,comment)
    @user = user
    @comment = comment
    mail(:to => user.email, :subject => "New comment on '"+comment.node.title+"'")
  end

end
