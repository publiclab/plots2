class SubscriptionMailer < ActionMailer::Base
  default from: "do-not-reply@publiclab.org"

  # SubscriptionMailer.notify(node).deliver 
  def notify_node_creation(node)
    # figure out who needs to get an email, no dupes
    subject = "[PublicLab] " + node.title
    get_tag_subscribers(node).each do |key,val|
      @user = val[:user]
      @node = node
      @tags = val[:tags]
      mail(:to => val[:user].email, :subject => subject).deliver
    end
  end

  # SubscriptionMailer.notify(user,self).deliver 
  def notify_note_liked(node,user)
    # figure out who needs to get an email, no dupes
    subject = "[PublicLab] #{user.username} liked your research note"
    @user = user
    @node = node
    mail(:to => node.author.email, :subject => subject).deliver
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
  # we can do this in the model. i think we already have a method like this.
  def get_node_tags(node)
    # find all tags for the node
    # Currently tag names and tids aren't 1:1 even though they are supposed to be; there are duplicates. 
    # Rewrite tag creation code and migrate to eliminate this,
    # but in the meantime, search tags by tagname, not tid
    tids = []
    node.tagnames.each do |tagname|
      # sadly, Drupal has 2 different tag tables. 
      # We are only using "community_tags" but have to include the other for legacy support
      tids += DrupalTag.find_all_by_name(tagname).collect(&:tid)
    end
    tids
  end

  # Given a node, find all tags for that node and then all users following
  # that tag. Return a dictionary of tags indexed by user.
  def get_tag_subscribers(node)
    tids = get_node_tags(node)
    # include special tid for indiscriminant subscribers who want it all!
    tids += [-1,]
    usertags = TagSelection.find(:all, :conditions => ["tid IN (?) AND following = true",tids])
    d = {}
    usertags.each do |usertag|
      # For each row of (user,tag), build a user's tag subscriptions 
      d[usertag.user.name] = {:user => usertag.user}
      d[usertag.user.name][:tags] = Set.new if d[usertag.user.name][:tags].nil?
      if usertag.tag.nil?
        # name the magic tag appropriately so emails make sense.
        # this is because the magic tag does not exist in the database
        # NB this wouldn't be possible if foreign key constraints existed b/c
        # an actual tag would have to be added into the database -btb
        d[usertag.user.name][:tags].add('all notes EVAR!1!')
      else
        d[usertag.user.name][:tags].add(usertag.tag)
      end
    end
    return d
  end
end
