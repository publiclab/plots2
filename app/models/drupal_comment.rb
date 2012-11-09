class DrupalComment < ActiveRecord::Base
  belongs_to :drupal_node, :foreign_key => 'nid'
  has_one :drupal_users, :foreign_key => 'uid'

  self.table_name = 'comments'
  self.primary_key = 'cid'

  def self.inheritance_column
    "rails_type"
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

end
