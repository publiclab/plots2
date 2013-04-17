class SubscriptionMailer < ActionMailer::Base
  default from: "do-not-reply@publiclab.org"

  # SubscriptionMailer.notify(user,self).deliver 
  def notify_node_creation(node)
    # figure out who needs to get an email, no dupes
    subject = "[PublicLab] new post '" + node.title + "'"
    get_tag_subscribers(node).each do |user, tags|
      # This might not work because it expects a single call to mail?
      @user = user
      @node = node
      @tags = tags
      mail(:to => user.email, :subject => subject)
    end
  end

  private

  # Return all users subscribed to the given node as keys to a dictionary of
  # sets, each set contains a reference to the node.
  def get_node_subscribers(node)
    users = NodeSelection.find_by_nid_and_following(node.nid, true)
    d = {}
    users.each do |user|
      d[user] = [node].to_set
    end
    return d
  end

  # Fetch all the tag ids associated with a node.
  def get_node_tags(node)
    # find all tags for the node
    DrupalTag.find_by_drupal_node(node.nid).map do |tag|
      # map the list of tag objects into a list of tids
      tag.tid
    end
  end

  # Given a node, find all tags for that node and then all users following
  # that tag. Return a dictionary of tags indexed by user.
  def get_tag_subscribers(node)
    tags = get_node_tags(node)
    usertags = TagSelection.where(:tid => tags, :following => true)
    d = {}
    d.default = Set.new
    usertags.each do |usertag|
      # For each row of (user,tag), build a user's tag subscriptions 
      d[usertag.user] = d[usertag.user].add(usertag.tag)
    end
    return d
  end
end
