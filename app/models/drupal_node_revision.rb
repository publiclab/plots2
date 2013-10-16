class DrupalNodeRevision < ActiveRecord::Base
  attr_accessible :title, :body, :nid, :uid, :teaser, :log, :timestamp, :format
  self.table_name = 'node_revisions'
  self.primary_key = 'vid'

  belongs_to :drupal_node, :foreign_key => 'nid', :dependent => :destroy
  has_one :drupal_users, :foreign_key => 'uid'

  validates :title, 
    :presence => :true, 
    :length => { :minimum => 2, :maximum => 100 },
    :format => {:with => /[A-Z][\w\-_]*/i, :message => "can only include letters, numbers, and dashes"}
  validates :body, :presence => :true
  validates :uid, :presence => :true
  validates :nid, :presence => :true

  def created_at
    Time.at(self.timestamp)
  end

  def author
    DrupalUsers.find_by_uid self.uid
  end

  def parent
    self.drupal_node
  end

  def render_body
    body = self.body || ""
    body = RDiscount.new(body, :generate_toc)
    body.to_html
  end

end
