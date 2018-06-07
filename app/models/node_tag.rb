class NodeTag < ApplicationRecord
  self.table_name = 'community_tags'
  self.primary_keys = :tid, :nid
  belongs_to :node, foreign_key: 'nid'
  belongs_to :tag, foreign_key: 'tid'
  belongs_to :drupal_users, foreign_key: 'uid'
  accepts_nested_attributes_for :tag

  after_create :increment_count

  def increment_count
    tag = self.tag
    tag.count = 0 if tag.count.nil?
    tag.count += 1
    tag.save
  end

  def author
    user
  end

  def new_author_contributor
    @uid = self.uid
    return "<span class = 'label label-success'><i>New Contributor</i></span>".html_safe if Node.where(:uid => @uid).length === 1
  end

  def user
    DrupalUser.find_by(uid: uid).try(:user)
  end

  def drupal_user
    DrupalUser.find uid
  end

  def name
    tag.name
  end

  def description
    self.tag.description if self.tag&.description && !self.tag.description.empty?
  end

end
