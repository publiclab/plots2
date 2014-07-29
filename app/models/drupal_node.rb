class UniqueUrlValidator < ActiveModel::Validator
  def validate(record)
    if record.title == "" || record.title.nil?
      #record.errors[:base] << "You must provide a title." 
      # otherwise the below title uniqueness check fails, as title presence validation doesn't run until after
    elsif record.title == "new" && (record.type == "page" || record.type == "place" || record.type == "tool")
      record.errors[:base] << "You may not use the title 'new'." # otherwise the below title uniqueness check fails, as title presence validation doesn't run until after
    else
      if !DrupalNode.where(path: record.generate_path).first.nil? && record.type == "note"
        record.errors[:base] << "You have already used this title today."
      end
    end
  end
end

class DrupalNode < ActiveRecord::Base
  attr_accessible :title, :uid, :status, :type, :vid, :cached_likes, :comment, :path
  self.table_name = 'node'
  self.primary_key = 'nid'

  has_many :drupal_node_revision, :foreign_key => 'nid', :dependent => :destroy
# wasn't working to tie it to .vid, manually defining below
#  has_one :drupal_main_image, :foreign_key => 'vid', :dependent => :destroy
#  has_many :drupal_content_field_image_gallery, :foreign_key => 'nid'
  has_one :drupal_node_counter, :foreign_key => 'nid', :dependent => :destroy
  has_many :drupal_upload, :foreign_key => 'nid', :dependent => :destroy
  has_many :drupal_files, :through => :drupal_upload
    has_many :drupal_node_community_tag, :foreign_key => 'nid', :dependent => :destroy
    has_many :drupal_tag, :through => :drupal_node_community_tag
    # these override the above... have to do it manually:
    # has_many :drupal_tag, :through => :drupal_node_tag
  has_many :drupal_comments, :foreign_key => 'nid', :dependent => :destroy
  has_many :drupal_content_type_map, :foreign_key => 'nid', :dependent => :destroy
  has_many :drupal_content_field_bboxes, :foreign_key => 'nid'
  has_many :drupal_content_field_mappers, :foreign_key => 'nid', :dependent => :destroy
  has_many :drupal_content_field_map_editor, :foreign_key => 'nid', :dependent => :destroy

  has_many :images, :foreign_key => :nid
  has_many :node_selections, :foreign_key => :nid

  validates :title, :presence => :true
  validates_with UniqueUrlValidator, :on => :create
  validates :path, :uniqueness => { :scope => :nid, :message => "This title has already been taken" }

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
  before_validation :set_path, on: :create

  private

  def set_path
    self.path = self.generate_path if self.path.blank? && !self.title.blank?
  end

  def set_changed_and_created
    self['changed'] = DateTime.now.to_i
  end

  # determines URL ("slug"), initializes the view counter, and sets up a created timestamp
  def setup
    self['created'] = DateTime.now.to_i
    self.save
    DrupalNodeCounter.new({:nid => self.id}).save
  end

  public

  def self.weekly_tallies(type = "note",span = 52)
    weeks = {}
    (0..span).each do |week|
      weeks[span-week] = DrupalNode.count :all, :select => :created, :conditions => {:type => type, :status => 1, :created => Time.now.to_i-week.weeks.to_i..Time.now.to_i-(week-1).weeks.to_i}
    end
    weeks
  end

  def current_revision
    # Grab the most recent revision for this node.
    self.drupal_node_revision.order(timestamp: "DESC").last
  end

  def current_title
    # Grab the title from the most recent revision for this node.
    current_revision.title
  end

  def files
    self.drupal_files
  end

  def likes
    self.cached_likes
  end

  # users who like this node
  def likers
    self.node_selections.where(:liking => true).collect(&:user)
  end

  def liked_by(uid)
    self.likers.collect(&:uid).include?(uid)
  end

  def generate_path
    if self.type == 'note'
      username = DrupalUsers.find_by_uid(self.uid).name
      "/notes/"+username+"/"+Time.now.strftime("%m-%d-%Y")+"/"+self.title.parameterize
    elsif self.type == 'page'
      "/wiki/"+self.title.parameterize
    elsif self.type == 'map'
      "/map/"+self.title.parameterize+"/"+Time.now.strftime("%m-%d-%Y")
    end
  end

  # ============================================
  # Manual associations: 

  def latest
    self.drupal_node_revision.sort_by { |rev| rev.timestamp }.last
  end

  def revisions
    self.drupal_node_revision.sort_by { |rev| rev.timestamp }
  end

  def revision_count
    self.drupal_node_revision.size
  end

  def comment_count
    self.drupal_comments.size
  end

  def comments
    self.drupal_comments.order(timestamp: :desc)
  end

  def author
    DrupalUsers.find_by_uid self.uid
  end

  def coauthors
    User.find_all_by_username(self.power_tags('with')) if self.has_power_tag('with')
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
    DrupalMainImage.find :last, :conditions => ['nid = ? AND field_main_image_fid IS NOT NULL',self.nid]
  end

  # provide either a Drupally main_iamge or a Railsy one 
  def main_image(node_type = :all)
    return nil if self.images.empty?
    if (self.type == "place" || self.type == "tool") && self.images.length == 0 # special handling... oddly needed:
      DrupalMainImage.find(:last, :conditions => {:nid => self.id}, :order => "field_main_image_fid").drupal_file
    else
      if self.images.length > 0 && node_type != :drupal
        self.images.last 
      elsif self.drupal_main_image && node_type != :rails
        self.drupal_main_image.drupal_file 
      else
        nil
      end
    end
  end

  # was unable to set up this relationship properly with ActiveRecord associations
  def drupal_content_field_image_gallery
    DrupalContentFieldImageGallery.find :all, :conditions => {:nid => self.nid}, :order => "field_image_gallery_fid"
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
    # self.has_tag('chapter')
    self.slug[0..5] == 'place/'
  end

  # ============================================
  # Tag-related methods

  def has_mailing_list?
    self.has_power_tag("list")
  end

  def responded_to
    DrupalNode.find_all_by_nid(self.power_tags("response")) || []
  end

  def responses
    DrupalTag.find_nodes_by_type(["response:"+self.id.to_s])
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

  # returns all results as whole tag (node) objects
  def power_tag_objects(tag)
    DrupalNodeCommunityTag.find(:all,:conditions => ['nid = ? AND tid IN (?)',self.id,DrupalTag.find(:all, :conditions => ["name LIKE ?",tag+":%"]).collect(&:tid)])
  end

  # return whole tag objects but no powertags or "event"
  def normal_tags
    node_tags = DrupalNodeCommunityTag.find(:all,:conditions => ['nid = ? AND tid IN (?)',self.id,DrupalTag.find(:all, :conditions => ["name NOT LIKE ? AND name NOT LIKE ?","%:%","event"]).collect(&:tid)])
    tags = []
    node_tags.each do |nt|
      tags << nt
    end
    tags
  end

  def has_tag(tag)
    DrupalNodeCommunityTag.find(:all,:conditions => ['nid IN (?) AND tid IN (?)',self.id,DrupalTag.find_all_by_name(tag).collect(&:tid)]).length > 0
  end

  # has it been tagged with "list:foo" where "foo" is the name of a Google Group?
  def mailing_list
    begin
      if true#Rails.env == "production"
        Rails.cache.fetch("feed-"+self.id.to_s+"-"+(self.updated_at.to_i/300).to_i.to_s) do
          RSS::Parser.parse(open('https://groups.google.com/group/'+self.power_tag('list')+'/feed/rss_v2_0_topics.xml').read, false).items
        end
      else
        return []
      end
    rescue
      return []
    end
  end

  # End of tag-related methods

  # used in typeahead autocomplete search results
  def icon
   icon = "<i class='icon-file'></i>" if self.type == "note"
   icon = "<i class='icon-book'></i>" if self.type == "page"
   icon = "<i class='icon-map-marker'></i>" if self.type == "map"
   icon = "<i class='icon-flag'></i>" if self.type == "place"
   icon = "<i class='icon-wrench'></i>" if self.type == "tool"
   icon
  end

  def tags
    self.drupal_tag
  end

  def tagnames
    self.tags.collect(&:name)
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

  # is this used anymore? deprecate?
  def slug
    self.path.split('/').last
  end

  def edit_path
    if self.type == "page" || self.type == "tool" || self.type == "place"
      if self.language != ""
        path = "/wiki/edit/" + self.language + "/" + self.path.split("/").last
      else
        path = "/wiki/edit/" + "/" + self.path.split("/").last
      end
    else
      path = "/notes/edit/"+self.id.to_s
    end
    path
  end

  def self.find_by_slug(title)
    DrupalNode.where(path: ["/#{title}", "/tool/#{title}", "/wiki/#{title}", "/place/#{title}"]).first
  end

  def self.find_root_by_slug(title)
    DrupalNode.where(path: ["/#{title}"]).first
  end

  def self.find_map_by_slug(title)
    DrupalNode.where(path: "/map/#{title}").first
  end

  def map
    # This fires off a query that orders by vid DESC
    # and is quicker than doing .order(vid: :DESC) for some reason.
    self.drupal_content_type_map.last
  end

  def locations
    self.drupal_content_field_bboxes.collect(&:field_bbox_geo)
  end 

  def location
    locations = []
    self.locations.each do |l|
      locations << l if l && l.x && l.y
    end
    # cheap divide by zero hack
    {:x => locations.collect(&:x).sum/(locations.length+0.000001),:y => locations.collect(&:y).sum/(locations.length+0.000001)}
  end 

  def lat
    if self.has_power_tag("lat")
      self.power_tag("lat").to_f 
    else
      false
    end
  end

  def lon
    if self.has_power_tag("lon")
      self.power_tag("lon").to_f 
    else
      false
    end
  end

  # these should eventually displace the above means of finding locations
  # ...they may already be redundant after tagged_map_coord migration 
  def tagged_lat
    self.power_tags('lat')[0]
  end

  def tagged_lon
    self.power_tags('lon')[0]
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
    c = DrupalComment.new({
      :pid => 0,
      :nid => self.nid,
      :uid => params[:uid],
      :subject => "",
      :hostname => "",
      :comment => params[:body],
      :status => 0,
      :format => 1,
      :thread => thread,
      :timestamp => DateTime.now.to_i
    })
    c.save
    c
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
    if node.valid? # is this not triggering title uniqueness validation?
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
          if params[:main_image] and params[:main_image] != ''
            img = Image.find params[:main_image]
            img.nid = node.id
            img.save
          end
          node.save!
        else
          saved = false
          node.destroy
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
          node.destroy # clean up
        end
      end
    end
    return [saved,node,revision]
  end

  # same as new_note or new_wiki but with arbitrary type -- use for maps, DRY out new_note and new_wiki
  def self.new_node(params)
    saved = false
    node = DrupalNode.new({
      :uid => params[:uid],
      :title => params[:title],
      :type => params[:type]
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
          node.destroy # clean up
        end
      end
    end
    return [saved,node,revision]
  end

  def barnstar
    self.power_tag_objects('barnstar').first
  end

  def barnstars
    self.power_tag_objects('barnstar')
  end

  def add_barnstar(tagname,user)
    self.add_tag(tagname,user.drupal_user)
    # don't bother checking if it worked
    CommentMailer.notify_barnstar(self.author.user,self)
  end

  def add_tag(tagname,user)
    tagname = tagname.downcase
    unless self.has_tag(tagname)
      saved = false
      tag = DrupalTag.find_by_name(tagname) || DrupalTag.new({
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

end
