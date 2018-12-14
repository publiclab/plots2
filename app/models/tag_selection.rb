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

  #Given a tagList unsubscribe to the tags which are present in tagList
  # and are subscribed till yet
  # method for unchecked radio buttons
  def subscribe_multiple_tags(tag_list, user_id)
      #Step 1 : Fetch subscribed tags from tag_list
      tag_list = tag_selection.where(following)
      #Step 2 : Unubscribe to all the tags in the tag_list
  end
end
