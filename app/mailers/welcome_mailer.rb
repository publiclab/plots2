class PasswordResetMailer < ActionMailer::Base
  #default from: "do-not-reply@publiclab.org"

  # PasswordResetMailer.reset_notify(user).deliver 
  def add_to_list(user,list)
    subject = "subscribe"
    @list = list
    mail(:to => list+'+subscribe@googlegroups.com', :subject => subject, :from => user.mail).deliver
  end

end
