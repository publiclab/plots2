class DrupalNodeRevision < ActiveRecord::Base
  attr_accessible :title, :body, :nid, :uid, :teaser, :log, :timestamp, :format
  belongs_to :drupal_node, :foreign_key => 'nid'
  has_one :drupal_users, :foreign_key => 'uid'

  self.table_name = 'node_revisions'
  self.primary_key = 'vid'

  def created_at
    Time.at(self.timestamp)
  end

  def author
    DrupalUsers.find_by_uid self.uid
  end

end
