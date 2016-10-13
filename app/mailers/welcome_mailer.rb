class WelcomeMailer < ActionMailer::Base
  #default from: "do-not-reply@#{Rails.root}"

  # PasswordResetMailer.reset_notify(user).deliver 
  def add_to_list(user,list)
    subject = "subscribe"
    @list = list
    mail(:to => list+'+subscribe@googlegroups.com', :subject => subject, :from => user.email).deliver
  end

end
