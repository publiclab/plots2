class DrupalComment < ActiveRecord::Base
  attr_accessible :pid, :nid, :uid, :subject, :hostname, :comment, :status, :format, :thread, :timestamp 

  belongs_to :drupal_node, :foreign_key => 'nid', :touch => true, :dependent => :destroy, :counter_cache => true
  has_one :drupal_users, :foreign_key => 'uid'


  validates :comment,  :presence => true

  self.table_name = 'comments'
  self.primary_key = 'cid'

  def self.inheritance_column
    "rails_type"
  end

  def id
    self.cid
  end

  def created_at
    Time.at(self.timestamp)
  end

  def body
    comment.gsub(/(\s?)\@(\w+)/,'\1[@\2](/profile/\2)')
  end

  def author
    DrupalUsers.find_by_uid self.uid
  end

  def icon
    "<i class='icon-comment'></i>"
  end

  def type
    "comment"
  end

  def tags
    []
  end

  def next_thread
    (self.thread.split('/').first.to_i(16)+1).to_s(16).rjust(2, '0')+"/"
  end

  def parent
    self.drupal_node
  end

  def node
    self.drupal_node
  end

  # users who are involved in this comment thread
  def thread_participants
    
  end

  def mentioned_users
    usernames = self.comment.scan(/\s?\@(\w+)/)
    User.find_all_by_username(usernames.map {|m| m[0] }).uniq
  end

  # email all users in this thread 
  def notify(current_user)
    CommentMailer.notify_note_author(self.parent.author,self).deliver if self.parent.uid != current_user.uid
    # notify_callout_users
    self.mentioned_users.each do |user|
      CommentMailer.notify_callout(self,user) if user.username != self.author.username
    end
    already = self.mentioned_users.collect(&:uid)
    uids = []
    (self.parent.comments.collect(&:uid) + [self.parent.uid]).uniq.each do |u|
      uids << u unless already.include?(u)
    end
    DrupalUsers.find(:all, :conditions => ['uid IN (?)',uids]).each do |user|
      CommentMailer.notify(user.user,self).deliver if user.uid != current_user.uid && user.uid != self.uid && self.parent.uid != user.uid
    end 
  end

end
