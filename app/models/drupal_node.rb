class DrupalNode < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :drupal_node_revision, :foreign_key => 'nid'
  has_one :drupal_main_image, :foreign_key => 'nid'
  has_many :drupal_node_tag, :foreign_key => 'nid'
  has_many :drupal_tag, :through => :drupal_node_tag
  has_many :drupal_comments, :foreign_key => 'nid'
  has_one :drupal_content_type_map, :foreign_key => 'nid'
  has_many :drupal_content_field_bboxes, :foreign_key => 'nid'

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
    DrupalUsers.find self.uid
  end

  # for wikis:
  def authors
    self.revisions.collect(&:author).uniq
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

   def icon
    icon = "<i class='icon-file'></i>" if self.type == "note"
    icon = "<i class='icon-book'></i>" if self.type == "page"
    icon = "<i class='icon-map-marker'></i>" if self.type == "map"
    icon
   end

  def id
    self.nid
  end

  def tags
    self.drupal_tag.uniq
  end

  def comments
    self.drupal_comments
  end

  def slug
    if self.type == "page"
      slug = DrupalUrlAlias.find_by_src('node/'+self.id.to_s).dst.split('/').last 
    else
      slug = DrupalUrlAlias.find_by_src('node/'+self.id.to_s).dst
    end
    slug
  end

  def self.find_by_slug(title)
    urlalias = DrupalUrlAlias.find_by_dst('wiki/'+title)
    urlalias.node if urlalias
  end

  def self.find_root_by_slug(title)
    DrupalUrlAlias.find_by_dst(title).node
  end

  def self.find_map_by_slug(title)
    urlalias = DrupalUrlAlias.find_by_dst('map/'+title,:order => "pid DESC")
    urlalias.node if urlalias
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

  def map
    self.drupal_content_type_map
  end

  def location
    {:x => self.locations.collect(&:x).sum/self.locations.length,:y => self.locations.collect(&:y).sum/self.locations.length}
  end 

  def locations
    self.drupal_content_field_bboxes.collect(&:field_bbox_geo)
  end 

end
