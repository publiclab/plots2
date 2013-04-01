class DrupalComment < ActiveRecord::Base
  belongs_to :drupal_node, :foreign_key => 'nid', :touch => true
  has_one :drupal_users, :foreign_key => 'uid'

  validates :comment,  :presence => true

  self.table_name = 'comments'
  self.primary_key = 'cid'

  before_save :notify

  def self.inheritance_column
    "rails_type"
  end

  def id
    self.cid
  end

  def created_at
    Time.at(self.timestamp)
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

  # run email/other notifications
  def notify
    # email all users in this thread 
  end

end
