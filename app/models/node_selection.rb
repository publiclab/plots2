class NodeSelection < ActiveRecord::Base
  attr_accessible :following, :liking
  self.primary_keys = :user_id, :nid
  # belongs_to :user
  belongs_to :node, :foreign_key => :nid
  belongs_to :drupal_users, :foreign_key => :user_id

  def user
    User.find_by_username(DrupalUsers.find_by_uid(self.user_id).name)
  end

end
