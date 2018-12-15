class TagSelection < ApplicationRecord
  self.primary_keys = :user_id, :tid
  belongs_to :tag, foreign_key: :tid
  has_many :node_tags, foreign_key: :tid

  validates :user_id, presence: :true
  validates :tid, presence: :true
  validates :tag, presence: :true

  def user
    DrupalUser.find_by(uid: user_id)
  end

  def ruser
    User.find_by(id: user_id)
  end

  def tagname
    tag.name
  end

  #Given a tagList subscribe to the tags which are checked in tagList
  # and unsubscribe to tags unchecked in the tag_list
  def subscribe_multiple_tags(node, user, tag_list)
      for node.tags do |t|
        value = tag_list[t.tid]
        subscription = TagSelection.where(:user_id => user.uid,
                                          :tid => t.tid).first_or_create
        subscription.following = value
        if subscription.following_changed?
          subscription.save!
        end
      end
  end

end
