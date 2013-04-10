class CommentMailer < ActionMailer::Base
  default from: "do-not-reply@publiclab.org"

  def notify_of_comment(user,comment)
    @comment = comment
    @user = user
    mail(:to => user.email, :subject => "New comment on '"+comment.node.title+"'")
  end

end
