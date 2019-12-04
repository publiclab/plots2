class NodeSelection < ApplicationRecord
  self.primary_keys = :user_id, :nid
  # belongs_to :user
  belongs_to :node, foreign_key: :nid
  belongs_to :user, foreign_key: :user_id
end
