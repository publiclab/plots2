class NodeSelection < ActiveRecord::Base
  attr_accessible :following, :liking
  belongs_to :user
  belongs_to :drupal_node, :foreign_key => 'nid'

  def node
    self.drupal_node
  end

end
