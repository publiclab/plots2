class SubscriptionMailer < ActionMailer::Base
  default from: "do-not-reply@publiclab.org"

  # SubscriptionMailer.notify(user,self).deliver 
  def notify_node_creation(node)
    # figure out who needs to get an email, no dupes
    #mail(:to => user.email, :subject => "[PublicLab] ... on '"+node.title+"'")
  end

end
