class DrupalNode < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :drupal_node_revision, :foreign_key => 'nid'
  has_one :drupal_main_image, :foreign_key => 'nid'
  has_many :drupal_node_tag, :foreign_key => 'nid'
  has_many :drupal_tag, :through => :drupal_node_tag

  self.table_name = 'node'
  self.primary_key = 'nid'
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name == 'changed'
      return true if method_name == 'changed?'
      super
    end
  end

  def self.inheritance_column
    "rails_type"
  end

  def author
    self.latest.author
  end

  def created_at
    Time.at(self.drupal_node_revision.last.timestamp)
  end

  def body
    self.drupal_node_revision.last.body
  end

  def main_image
    self.drupal_main_image.drupal_file if self.drupal_main_image
  end

  def id
    self.nid
  end

  def tags
    self.drupal_tag.uniq
  end

  def slug
    DrupalUrlAlias.find_by_src('node/'+self.id.to_s).dst.split('/')[1]
  end

  def self.find_by_slug(title)
    DrupalUrlAlias.find_by_dst('wiki/'+title).node
  end

  def latest
    self.drupal_node_revision.last
  end

  def revisions
    DrupalNodeRevision.find_all_by_nid(self.nid,:order => "timestamp DESC")
  end

  def revision_count
    DrupalNodeRevision.count_by_nid(self.nid)
  end

end
