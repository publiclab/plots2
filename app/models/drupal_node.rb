require 'rss'

class UniqueUrlValidator < ActiveModel::Validator
  def validate(record)
    if record.title == "" || record.title.nil?
      record.errors[:base] << "You must provide a title." # otherwise the below title uniqueness check fails, as title presence validation doesn't run until after
    else
      if !DrupalUrlAlias.find_by_dst(record.generate_path).nil? && record.type == "note"
      record.errors[:base] << "You have already used this title today."
      end
    end
  end
end

class DrupalNode < ActiveRecord::Base
  attr_accessible :title, :uid, :status, :type, :vid, :cached_likes, :comment
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
  validates_with UniqueUrlValidator, :on => :create

  # making drupal and rails database conventions play nice
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name == 'changed'
      return true if method_name == 'changed?'
      super
    end
  end

  # making drupal and rails database conventions play nice
  def self.inheritance_column
    "rails_type"
  end

  before_save :set_changed_and_created
  after_create :setup
  before_destroy :delete_url_alias

  private

  def set_changed_and_created
    self['changed'] = DateTime.now.to_i
  end

  # determines URL ("slug"), initializes the view counter, and sets up a created timestamp
  def setup
    self['created'] = DateTime.now.to_i
    self.save
    current_user = User.find_by_username(DrupalUsers.find_by_uid(self.uid).name)
    if self.type == "note"
      slug = DrupalUrlAlias.new({
        :dst => self.generate_path,
        :src => "node/"+self.id.to_s
      }).save
    else
      slug = DrupalUrlAlias.new({
        :dst => self.generate_path,
        :src => "node/"+self.id.to_s
      }).save
    end
    counter = DrupalNodeCounter.new({:nid => self.id}).save
  end

  def delete_url_alias
    url_alias = DrupalUrlAlias.find_by_src("node/"+self.nid.to_s)
    url_alias.delete if url_alias
  end

  public

  def likes
    self.cached_likes
  end

  def generate_path
    username = DrupalUsers.find_by_uid(self.uid).name
    if self.type == 'note'
      "notes/"+username+"/"+Time.now.strftime("%m-%d-%Y")+"/"+self.title.parameterize
    elsif self.type == 'page'
      "wiki/"+self.title.parameterize
    elsif self.type == 'map'
      #...
    end
  end

  # ============================================
  # Manual associations: 

  def latest
    DrupalNodeRevision.find_by_nid(self.nid,:order => "timestamp DESC")
  end

  def revisions
    DrupalNodeRevision.find_all_by_nid(self.nid,:order => "timestamp DESC")
  end

  def revision_count
    DrupalNodeRevision.count_by_nid(self.nid)
  end

  def comment_count
    DrupalComment.count :all, :conditions => {:nid => self.nid}
  end

  def comments
    DrupalComment.find_all_by_nid self.nid, :order => "timestamp", :conditions => {:status => 0}
  end

  def author
    DrupalUsers.find self.uid
  end

  # for wikis:
  def authors
    self.revisions.collect(&:author).uniq
  end

  # view adaptors for typical rails db conventions so we can migrate someday
  def id
    self.nid
  end
  def created_at
    Time.at(self.created)
  end
  def updated_at
    Time.at(self['changed'])
  end

  def body
    if self.latest
      self.latest.body
    else
      nil
    end
  end

  # was unable to set up this relationship properly with ActiveRecord associations
  def drupal_main_image
    DrupalMainImage.find :last, :conditions => {:nid => self.nid}
  end

  # provide either a Drupally main_iamge or a Railsy one 
  def main_image(node_type = :all)
    if self.drupal_main_image && node_type != :rails
      self.drupal_main_image.drupal_file 
    elsif node_type != :drupal && self.images
      self.images.last 
    else
      nil
    end
  end

  # was unable to set up this relationship properly with ActiveRecord associations
  def drupal_content_field_image_gallery
    DrupalContentFieldImageGallery.find_all_by_vid self.vid
  end

  def gallery
    if self.drupal_content_field_image_gallery.length > 0 && self.drupal_content_field_image_gallery.first.field_image_gallery_fid 
      return self.drupal_content_field_image_gallery 
    else
      return []
    end
  end

  # base this on a tag!
  def is_place?
    self.slug[0..5] == 'place/'
  end

  # ============================================
  # Tag-related methods

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

  # has it been tagged with "list:foo" where "foo" is the name of a Google Group?
  def mailing_list
    Rails.cache.fetch("feed-"+self.id.to_s+"-"+(self.updated_at.to_i/300).to_i.to_s) do
      RSS::Parser.parse(open('https://groups.google.com/group/'+self.power_tag('list')+'/feed/rss_v2_0_topics.xml').read, false).items
    end
  end

  # End of tag-related methods

  # used in typeahead autocomplete search results
  def icon
   icon = "<i class='icon-file'></i>" if self.type == "note"
   icon = "<i class='icon-book'></i>" if self.type == "page"
   icon = "<i class='icon-map-marker'></i>" if self.type == "map"
   icon
  end

  def tags
    (self.drupal_tag + DrupalTag.find(:all, :conditions => ["tid IN (?)",DrupalNodeCommunityTag.find_all_by_nid(self.nid).collect(&:tid)])).uniq
  end

  # increment view count
  def view
    DrupalNodeCounter.new({:nid => self.id}).save! if self.drupal_node_counter.nil? 
    self.drupal_node_counter.totalcount += 1
    self.drupal_node_counter.save
  end

  # view count
  def totalcount
    DrupalNodeCounter.new({:nid => self.id}).save! if self.drupal_node_counter.nil? 
    self.drupal_node_counter.totalcount
  end

  # ============================================
  # URL-related methods:

  def slug
    if self.type == "page" || self.type == "tool" || self.type == "place"
      slug = DrupalUrlAlias.find_by_src('node/'+self.id.to_s).dst.split('/').last if DrupalUrlAlias.find_by_src('node/'+self.id.to_s)
    else
      slug = DrupalUrlAlias.find_by_src('node/'+self.id.to_s).dst if DrupalUrlAlias.find_by_src('node/'+self.id.to_s)
    end
    slug
  end

  def path
    path = "/"+DrupalUrlAlias.find_by_src('node/'+self.id.to_s).dst
  end

  def edit_path
    if self.type == "page" || self.type == "tool" || self.type == "place"
      path = "/wiki/edit/"+DrupalUrlAlias.find_by_src('node/'+self.id.to_s).dst.split('/').last if DrupalUrlAlias.find_by_src('node/'+self.id.to_s)
    else
      path = "/notes/edit/"+self.id.to_s
    end
    path
  end

  def self.find_by_slug(title)
    urlalias = DrupalUrlAlias.find_by_dst('place/'+title)
    urlalias = urlalias || DrupalUrlAlias.find_by_dst('tool/'+title)
    urlalias = urlalias || DrupalUrlAlias.find_by_dst('wiki/'+title)
    urlalias = urlalias || DrupalUrlAlias.find_by_dst(title)
    if urlalias
      urlalias.node
    else
      nil
    end
  end

  def self.find_root_by_slug(title)
    slug = DrupalUrlAlias.find_by_dst(title)
    slug.node if slug
  end

  def self.find_map_by_slug(title)
    urlalias = DrupalUrlAlias.find_by_dst('map/'+title,:order => "pid DESC")
    urlalias.node if urlalias
  end

  def map
    DrupalContentTypeMap.find_by_nid(self.nid,:order => "created DESC")
  end

  def nearby_maps(dist = 1.5)
    minlat = self.lat - dist
    maxlat = self.lat + dist
    minlon = self.lon - dist
    maxlon = self.lon + dist
    # we have to read the GeoRuby docs to formulate a spatial query: 
    #DrupalContentFieldBbox.find :all, :limit => 20, :conditions => []
    []
  end

  def locations
    self.drupal_content_field_bboxes.collect(&:field_bbox_geo)
  end 

  def location
    locations = []
    self.locations.each do |l|
      locations << l if l && l.x && l.y
    end
    {:x => locations.collect(&:x).sum/locations.length,:y => locations.collect(&:y).sum/locations.length}
  end 

  def lat
    self.location[:y]
  end

  def lon
    self.location[:x]
  end

  def next_by_author
    DrupalNode.find :first, :conditions => ['uid = ? and nid > ? and type = "note"', self.author.uid, self.nid], :order => 'nid'
  end

  def prev_by_author
    DrupalNode.find :first, :conditions => ['uid = ? and nid < ? and type = "note"', self.author.uid, self.nid], :order => 'nid desc'
  end

  # ============================================
  # Automated constructors for associated models

  def add_comment(params = {})
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
    c if c.save!
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

  # handle creating a new note with attached revision and main image
  # this is kind of egregiously bad... must revise after 
  # researching simultaneous creation of associated records
  def self.new_note(params)
    saved = false
    node = DrupalNode.new({
      :uid => params[:uid],
      :title => params[:title],
      :comment => 2,
      :type => "note"
    })
    if node.valid?
      saved = true
      revision = false
      ActiveRecord::Base.transaction do
        node.save! 
        revision = node.new_revision({
          :nid => node.id,
          :uid => params[:uid],
          :title => params[:title],
          :body => params[:body]
        })
        if revision.valid?
          revision.save!
          node.vid = revision.vid
          # save main image
          if params[:main_image]
            img = Image.find params[:main_image]
            img.nid = node.id
            img.save
          end
          node.save!
        else
          saved = false
          node.destroy # clean up. But do this in the model!
        end
      end
    end
    return [saved,node,revision]
  end

  def self.new_wiki(params)
    saved = false
    node = DrupalNode.new({
      :uid => params[:uid],
      :title => params[:title],
      :type => "page"
    })
    if node.valid?
      revision = false
      saved = true
      ActiveRecord::Base.transaction do
        node.save! 
        revision = node.new_revision({
          :nid => node.id,
          :uid => params[:uid],
          :title => params[:title],
          :body => params[:body]
        })
        if revision.valid?
          revision.save!
          node.vid = revision.vid
          node.save!
        else
          saved = false
          node.destroy # clean up. But do this in the model!
        end
      end
    end
    return [saved,node,revision]
  end

  def add_tag(tagname,user)
    saved = false
    tag = DrupalTag.new({
      :vid => 3, # vocabulary id; 1
      :name => tagname,
      :description => "",
      :weight => 0
    })
    ActiveRecord::Base.transaction do
      if tag.valid?
        tag.save!
        node_tag = DrupalNodeCommunityTag.new({
          :tid => tag.id,
          :uid => user.uid,
          :date => DateTime.now.to_i,
          :nid => self.id
        })
        if node_tag.save
          saved = true
        else
          saved = false
          tag.destroy
        end
      end
    end
    return [saved,tag]
  end

end
