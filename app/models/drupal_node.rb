require 'rss'

class DrupalNode < ActiveRecord::Base
  attr_accessible :title, :uid, :status, :type, :vid
  self.table_name = 'node'
  self.primary_key = 'nid'

  has_many :drupal_node_revision, :foreign_key => 'nid', :dependent => :destroy
# wasn't working to tie it to .vid, manually defining below
#  has_one :drupal_main_image, :foreign_key => 'vid', :dependent => :destroy
#  has_many :drupal_content_field_image_gallery, :foreign_key => 'nid'
  has_one :drupal_node_counter, :foreign_key => 'nid', :dependent => :destroy
  has_many :drupal_node_tag, :foreign_key => 'nid', :dependent => :destroy
  has_many :drupal_tag, :through => :drupal_node_tag
# these override the above... have to do it manually:
#  has_many :drupal_node_community_tag, :foreign_key => 'nid'
#  has_many :drupal_tag, :through => :drupal_node_community_tag
  has_many :drupal_comments, :foreign_key => 'nid', :dependent => :destroy
  has_many :drupal_content_type_map, :foreign_key => 'nid'
  has_many :drupal_content_field_bboxes, :foreign_key => 'nid'
  has_many :images, :foreign_key => :nid

  validates :title, :presence => :true
  #validates :name, :format => {:with => /^[\w-]*$/, :message => "can only include letters, numbers, and dashes"}

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

  before_save :set_changed
  after_create :slug_and_counter
  before_destroy :delete_url_alias

  def set_changed
    self.changed = DateTime.now.to_i
  end

  def slug_and_counter
    slug = self.title.downcase.gsub(' ','-').gsub("'",'').gsub('"','').gsub('/','-')
    slug = DrupalUrlAlias.new({
      :dst => "wiki/"+slug,
      :src => "node/"+self.id.to_s
    }).save
    counter = DrupalNodeCounter.new({:nid => self.id}).save
  end

  def delete_url_alias
    DrupalUrlAlias.find_by_src("node/"+self.nid.to_s).delete
  end

  def author
    DrupalUsers.find self.uid
  end

  # for wikis:
  def authors
    self.revisions.collect(&:author).uniq
  end

  def created_at
    Time.at(self.drupal_node_revision.first.timestamp)
  end

  def updated_at
    self.updated_on
  end

  def updated_on
    Time.at(self.drupal_node_revision.last.timestamp)
  end

  def body
    if self.drupal_node_revision.length > 0
      self.drupal_node_revision.last.body
    else
      nil
    end
  end

  def drupal_main_image
    DrupalMainImage.find_by_vid self.vid
  end

  def main_image
    self.drupal_main_image.drupal_file if self.drupal_main_image
  end

  def drupal_content_field_image_gallery
    DrupalContentFieldImageGallery.find_all_by_vid self.vid
  end

  def gallery
    if self.drupal_content_field_image_gallery.first.field_image_gallery_fid 
      return self.drupal_content_field_image_gallery 
    else
      return []
    end
  end

  # base this on a tag!
  def is_place?
    self.slug[0..5] == 'place/'
  end

  def has_mailing_list?
    self.has_power_tag("list")
  end

  # power tags have "key:value" format, and should be searched with a "key:*" wildcard
  def has_power_tag(tag)
    DrupalNodeCommunityTag.find(:all,:conditions => ['nid = ? AND tid IN (?)',self.id,DrupalTag.find(:all, :conditions => ["name LIKE ?",tag+":%"]).collect(&:tid)]).length > 0
  end

  # returns the value for the most recent power tag of form key:value
  def power_tag(tag)
    node_tag = DrupalNodeCommunityTag.find(:last,:conditions => ['nid = ? AND tid IN (?)',self.id,DrupalTag.find(:all, :conditions => ["name LIKE ?",tag+":%"]).collect(&:tid)])
    if node_tag
      node_tag.name.gsub(tag+':','')
    else
      ''
    end
  end

  # returns all results
  def power_tags(tag)
    node_tags = DrupalNodeCommunityTag.find(:all,:conditions => ['nid = ? AND tid IN (?)',self.id,DrupalTag.find(:all, :conditions => ["name LIKE ?",tag+":%"]).collect(&:tid)])
    tags = []
    node_tags.each do |nt|
      tags << nt.name.gsub(tag+':','')
    end
    tags
  end

  def has_tag(tag)
    DrupalNodeTag.find(:all,:conditions => ['tid IN (?)',DrupalTag.find_all_by_name(tag).collect(&:tid)]).length > 0
  end

  def mailing_list
    Rails.cache.fetch("feed-"+self.id.to_s+"-"+(self.updated_at.to_i/300).to_i.to_s) do
      RSS::Parser.parse(open('https://groups.google.com/group/'+self.power_tag('list')+'/feed/rss_v2_0_topics.xml').read, false).items
    end
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
    (self.drupal_tag + DrupalTag.find(:all, :conditions => ["tid IN (?)",DrupalNodeCommunityTag.find_all_by_nid(self.nid).collect(&:tid)])).uniq
  end

  # increment view count
  def view
    self.drupal_node_counter.totalcount += 1
    self.drupal_node_counter.save
  end

  # view count
  def totalcount
    self.drupal_node_counter.totalcount
  end

  def comment_count
    DrupalComment.count :all, :conditions => {:nid => self.nid}
  end

  def comments
    DrupalComment.find_all_by_nid self.nid, :order => "timestamp", :conditions => {:status => 0}
  end

  def slug
    if self.type == "page"
      slug = DrupalUrlAlias.find_by_src('node/'+self.id.to_s).dst.split('/').last if DrupalUrlAlias.find_by_src('node/'+self.id.to_s)
    else
      slug = DrupalUrlAlias.find_by_src('node/'+self.id.to_s).dst if DrupalUrlAlias.find_by_src('node/'+self.id.to_s)
    end
    slug
  end

  def path
    path = "/"+DrupalUrlAlias.find_by_src('node/'+self.id.to_s).dst
  end

  def self.find_by_slug(title)
    urlalias = DrupalUrlAlias.find_by_dst('wiki/'+title)
    urlalias.node if urlalias
  end

  def self.find_root_by_slug(title)
    slug = DrupalUrlAlias.find_by_dst(title)
    slug.node if slug
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
    DrupalContentTypeMap.find_by_nid(self.nid,:order => "vid DESC")
  end

  def location
    locations = []
    self.locations.each do |l|
      locations << l if l && l.x && l.y
    end
    {:x => locations.collect(&:x).sum/locations.length,:y => locations.collect(&:y).sum/locations.length}
  end 

  def locations
    self.drupal_content_field_bboxes.collect(&:field_bbox_geo)
  end 

  def next_by_author
    DrupalNode.find :first, :conditions => ['uid = ? AND nid > ? AND type = "note"', self.author.uid, self.nid], :order => 'nid'
  end

  def prev_by_author
    DrupalNode.find :first, :conditions => ['uid = ? AND nid < ? AND type = "note"', self.author.uid, self.nid], :order => 'nid DESC'
  end

  def comment(params)
    if self.comments.length > 0
      thread = self.comments.last.next_thread
    else
      thread = "01/"
    end
    c = DrupalComment.new({})
    c.pid = 0
    c.nid = self.nid
    c.uid = params[:uid]
    c.subject = ""
    c.hostname = ""
    c.comment = params[:body]
    c.status = 0
    c.format = 1
    c.thread = thread
    c.timestamp = DateTime.now.to_i
    c.save!
  end

  def new_revision(params)
    DrupalNodeRevision.new({
      :nid => params[:nid],
      :uid => params[:uid],
      :title => params[:title],
      :body => params[:body],
      :teaser => "",
      :log => "",
      :timestamp => DateTime.now.to_i,
      :format => 1
    })
  end

end
