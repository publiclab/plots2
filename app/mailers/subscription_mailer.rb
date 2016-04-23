class SubscriptionMailer < ActionMailer::Base
  default from: "do-not-reply@publiclab.org"

  def notify_node_creation(node)
    subject = "[PublicLab] " + node.title
    DrupalTag.subscribers(node.tags).each do |key,val|
      @user = val[:user]
      @node = node
      @tags = val[:tags]
      mail(:to => val[:user].email, :subject => subject).deliver
    end
  end

  def notify_note_liked(node, user)
    subject = "[PublicLab] #{user.username} liked your research note"
    @user = user
    @node = node
    mail(:to => node.author.email, :subject => subject).deliver
  end

end
