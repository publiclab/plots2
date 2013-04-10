class NodeSelection < ActiveRecord::Base
  attr_accessible :following, :liking
  self.primary_keys = :user_id, :nid
  belongs_to :user
  belongs_to :drupal_node, :foreign_key => :nid

  def node
    self.drupal_node
  end

end
