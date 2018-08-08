class NodeSelection < ApplicationRecord
  self.primary_keys = :user_id, :nid
  # belongs_to :user
  belongs_to :node, foreign_key: :nid
  belongs_to :drupal_user, foreign_key: :user_id

  def user
    User.find_by(username: DrupalUser.find_by(uid: user_id).name)
  end

  def self.is_following?(user_id, node_id)
    selection = NodeSelection.where(user_id: user_id, nid: node_id)
    if selection.nil?
      return true
    else
      return selection
    end
  end
end
