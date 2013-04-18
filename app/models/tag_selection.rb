class TagSelection < ActiveRecord::Base
  attr_accessible :following
  self.primary_keys = :user_id, :tid
  belongs_to :drupal_tag, :foreign_key => :tid

  validates :user_id, :presence => :true
  validates :tid, :presence => :true

  def user
    DrupalUsers.find_by_uid self.user_id
  end

  def tag
    self.drupal_tag
  end

  def tagname
    self.drupal_tag.name
  end

end
