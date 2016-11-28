class UniqueUrlValidator < ActiveModel::Validator
  def validate(record)
    if record.title == "" || record.title.nil?
      #record.errors[:base] << "You must provide a title."
      # otherwise the below title uniqueness check fails, as title presence validation doesn't run until after
    elsif record.title == "new" && (record.type == "page" || record.type == "place" || record.type == "tool")
      record.errors[:base] << "You may not use the title 'new'." # otherwise the below title uniqueness check fails, as title presence validation doesn't run until after
    else
      if !Node.where(path: record.generate_path).first.nil? && record.type == "note"
        record.errors[:base] << "You have already used this title today."
      end
    end
  end
end

class Node < ActiveRecord::Base
  include NodeShared # common methods for node-like models

  attr_accessible :title, :uid, :status, :type, :vid, :cached_likes, :comment, :path, :slug
  self.table_name = 'node'
  self.primary_key = 'nid'

  searchable do
    text :title, boost: 5
    text :body do
      body.to_s.gsub!(/[[:cntrl:]]/,'')
    end
    time :updated_at
    string :status
    string :updated_month
    text :comments do
      comments.map { |comment| comment.comment }
    end

    string :user_name do
      users.name
    end
  end

  def updated_month
    updated_at.strftime('%B %Y')
  end


  extend FriendlyId
  friendly_id :friendly_id_string, use: [:slugged, :history]

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

  # friendly_id uses this method to set the slug column for nodes
  def friendly_id_string
    if self.type == 'note'
      username = Users.find_by_uid(self.uid).name
      "#{username} #{Time.at(self.created).strftime("%m-%d-%Y")} #{self.title}"
    elsif self.type == 'page'
      "#{self.title}"
    elsif self.type == 'map'
      "#{self.title} #{Time.at(self.created).strftime("%m-%d-%Y")}"
    end
  end

  has_many :node_revision, :foreign_key => 'nid', :dependent => :destroy
  # wasn't working to tie it to .vid, manually defining below
  #  has_one :main_image, :foreign_key => 'vid', :dependent => :destroy
  #  has_many :content_field_image_gallery, :foreign_key => 'nid'
  has_one :node_counter, :foreign_key => 'nid', :dependent => :destroy
  has_many :upload, :foreign_key => 'nid', :dependent => :destroy
  has_many :files, :through => :upload
  has_many :node_community_tag, :foreign_key => 'nid', :dependent => :destroy
  has_many :tag, :through => :node_community_tag
  # these override the above... have to do it manually:
  # has_many :tag, :through => :node_tag
  has_many :comments, :foreign_key => 'nid', :dependent => :destroy
  has_many :content_type_map, :foreign_key => 'nid', :dependent => :destroy
  has_many :content_field_mappers, :foreign_key => 'nid', :dependent => :destroy
  has_many :content_field_map_editor, :foreign_key => 'nid', :dependent => :destroy
  has_many :images, :foreign_key => :nid
  has_many :node_selections, :foreign_key => :nid
  has_many :answers, :foreign_key => :nid

  belongs_to :users, :foreign_key => 'uid'

  validates :title, :presence => :true
  validates_with UniqueUrlValidator, :on => :create
  validates :path, :uniqueness => { :message => "This title has already been taken" }

  # making  and rails database conventions play nice;
  # 'changed' is a reserved word in rails
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name == 'changed'
      return true if method_name == 'changed?'
      super
    end
  end

  # making  and rails database conventions play nice;
  # 'type' is a reserved word in rails
  def self.inheritance_column
    "rails_type"
  end

  before_save :set_changed_and_created
  after_create :setup
  before_validation :set_path, on: :create

  # can switch to a "question-style" path if specified
  def path(type = :default)
    if type == :question
      self[:path].gsub("/notes/", "/questions/")
    else
      # default path
      self[:path]
    end
  end

  # should only be run at actual creation time --
  # or, we should refactor to us node.created instead of Time.now
  def generate_path
    if self.type == 'note'
      username = Users.find_by_uid(self.uid).name
      "/notes/#{username}/#{Time.now.strftime("%m-%d-%Y")}/#{self.title.parameterize}"
    elsif self.type == 'page'
      "/wiki/" + self.title.parameterize
    elsif self.type == 'map'
      "/map/#{self.title.parameterize}/#{Time.now.strftime("%m-%d-%Y")}"
    end
  end

  private

  def set_path
    self.path = self.generate_path if self.path.blank? && !self.title.blank?
  end

# These methods are used for updating node paths upon changing the title
# friendly_id is being used for updating slugs and manage url redirects when an url changes
# removed due to issues discussed in https://github.com/publiclab/plots2/issues/691

#  def update_path
#    self.path = if self.type == 'note'
#                  username = Users.find_by_uid(self.uid).name
#                  "/notes/#{username}/#{Time.at(self.created).strftime("%m-%d-%Y")}/#{self.title.parameterize}"
#                elsif self.type == 'page'
#                  "/wiki/" + self.title.parameterize
#                elsif self.type == 'map'
#                  "/map/#{self.title.parameterize}/#{Time.at(self.created).strftime("%m-%d-%Y")}"
#                end
#  end

#  def remove_slug
#    if !FriendlyId::Slug.find_by_slug(self.title.parameterize).nil? && self.type == 'page'
#      slug = FriendlyId::Slug.find_by_slug(self.title.parameterize)
#      slug.delete
#    end
#  end

  def set_changed_and_created
    self['changed'] = DateTime.now.to_i
  end

  # determines URL ("slug"), initializes the view counter, and sets up a created timestamp
  def setup
    self['created'] = DateTime.now.to_i
    self.save
    NodeCounter.new({:nid => self.id}).save
  end

  public

  def self.weekly_tallies(type = "note", span = 52, time = Time.now)
    weeks = {}
    (0..span).each do |week|
      weeks[span-week] = Node.select(:created)
                                   .where(type:    type,
                                          status:  1,
                                          created: time.to_i - week.weeks.to_i..time.to_i - (week-1).weeks.to_i)
                                   .count
    end
    weeks
  end

  def notify
    if self.status == 4
      AdminMailer.notify_node_moderators(self)
    else
      SubscriptionMailer.notify_node_creation(self)
    end
  end

  def publish
    self.status = 1
    self.save
    self
  end

  def spam
    self.status = 0
    self.save
    self
  end

  def files
    self.files
  end

  # users who like this node
  def likers
    self.node_selections
        .joins(:users)
        .where(liking: true)
        .where('users.status = ?', 1)
        .collect(&:user)
  end

  def latest
    self.revisions
        .where(status: 1)
        .first
  end

  def revisions
    self.node_revision
        .order("timestamp DESC")
  end

  def revision_count
    self.node_revision
        .count
  end

  def comment_count
    self.comments
        .count
  end

  def author
    Users.find_by_uid self.uid
  end

  def coauthors
    User.find_all_by_username(self.power_tags('with')) if self.has_power_tag('with')
  end

  # for wikis:
  def authors
    self.revisions.collect(&:author).uniq
  end

  # tag- and node-based followers
  def subscribers(conditions = false)
    users = TagSelection.where(tid: self.tags.collect(&:tid))
                        .collect(&:user)
    users += NodeSelection.where(nid: self.nid)
                          .collect(&:user)

    users = users.where(conditions) if conditions
    users.uniq
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
  def main_image
    MainImage.order('vid')
                   .where('nid = ? AND field_main_image_fid IS NOT NULL', self.nid)
                   .last
  end

  # provide either a ly main_image or a Railsy one
  def main_image(node_type = :all)
    if self.images.length > 0 && node_type != :drupal
      if self.main_image_id.blank?
        self.images.order('vid').last
      else
        self.images.where(id: self.main_image_id).first
      end
    elsif self.main_image && node_type != :rails
      self.main_image.file
    else
      nil
    end
  end

  # was unable to set up this relationship properly with ActiveRecord associations
  def content_field_image_gallery
    ContentFieldImageGallery.where(nid: self.nid)
                                  .order("field_image_gallery_fid")
  end

  def gallery
    if self.content_field_image_gallery.length > 0 && self.content_field_image_gallery.first.field_image_gallery_fid
      return self.content_field_image_gallery
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

  # Nodes this node is responding to with a `response:<nid>` power tag;
  # The key word "response" can be customized, i.e. `replication:<nid>` for other uses.
  def responded_to(key = 'response')
    Node.find_all_by_nid(self.power_tags(key)) || []
  end

  # Nodes that respond to this node with a `response:<nid>` power tag;
  # The key word "response" can be customized, i.e. `replication:<nid>` for other uses.
  def responses(key = 'response')
    Tag.find_nodes_by_type([key+":"+self.id.to_s])
  end

  # Nodes that respond to this node with a `response:<nid>` power tag;
  # The key word "response" can be customized, i.e. `replication:<nid>` for other uses.
  def response_count(key = 'response')
    Node.where(status: 1, type: 'note')
              .includes(:node_revision, :tag)
              .where('term_data.name = ?', "#{key}:#{self.id}")
              .count
  end

  # power tags have "key:value" format, and should be searched with a "key:*" wildcard
  def has_power_tag(key)
    tids = Tag.includes(:node_community_tag)
                    .where("community_tags.nid = ? AND name LIKE ?", self.id, key + ":%")
                    .collect(&:tid)
    NodeCommunityTag.where('nid = ? AND tid IN (?)', self.id, tids).length > 0
  end

  # returns the value for the most recent power tag of form key:value
  def power_tag(tag)
    tids = Tag.includes(:node_community_tag)
                    .where("community_tags.nid = ? AND name LIKE ?", self.id, tag+":%")
                    .collect(&:tid)
    node_tag = NodeCommunityTag.where('nid = ? AND tid IN (?)', self.id, tids)
                                     .order('nid DESC')
    if node_tag && node_tag.first
      node_tag.first.tag.name.gsub(tag+':','')
    else
      ''
    end
  end

  # returns all tagnames for a given power tag
  def power_tags(tag)
    tids = Tag.includes(:node_community_tag)
                    .where("community_tags.nid = ? AND name LIKE ?", self.id, tag+":%")
                    .collect(&:tid)
    node_tags = NodeCommunityTag.where('nid = ? AND tid IN (?)', self.id, tids)
    tags = []
    node_tags.each do |nt|
      tags << nt.name.gsub(tag+':','')
    end
    tags
  end

  # returns all power tag results as whole community_tag objects
  def power_tag_objects(tag)
    tids = Tag.includes(:node_community_tag)
                    .where("community_tags.nid = ? AND name LIKE ?", self.id, tag+":%")
                    .collect(&:tid)
    NodeCommunityTag.where('nid = ? AND tid IN (?)', self.id, tids)
  end

  # return whole community_tag objects but no powertags or "event"
  def normal_tags
    tids = Tag.includes(:node_community_tag)
                    .where("community_tags.nid = ? AND name LIKE ?", self.id, "%:%")
                    .collect(&:tid)
    NodeCommunityTag.where('nid = ? AND tid NOT IN (?)', self.id, tids)
  end

  # accests a tagname /or/ tagname ending in wildcard such as "tagnam*"
  # also searches for other tags whose parent field matches given tagname,
  # but not tags matching given tag's parent field
  def has_tag(tagname)
    tags = self.get_matching_tags_without_aliasing(tagname)
    # search for tags with parent matching this
    tags += Tag.includes(:node_community_tag)
                     .where("community_tags.nid = ? AND parent LIKE ?", self.id, tagname)
    # search for parent tag of this, if exists
    #tag = Tag.where(name: tagname).try(:first)
    #if tag && tag.parent
    #  tags += Tag.includes(:node_community_tag)
    #                   .where("community_tags.nid = ? AND name LIKE ?", self.id, tag.parent)
    #end
    tids = tags.collect(&:tid).uniq
    NodeCommunityTag.where('nid IN (?) AND tid IN (?)', self.id, tids).length > 0
  end

  # can return multiple Tag records -- we don't yet hard-enforce uniqueness, but should soon
  # then, this would just be replaced by Tag.where(name: tagname).first
  def get_matching_tags_without_aliasing(tagname)
    tags = Tag.includes(:node_community_tag)
                    .where("community_tags.nid = ? AND name LIKE ?", self.id, tagname)
    # search for tags which end in wildcards
    if tagname[-1] == '*'
      tags += Tag.includes(:node_community_tag)
                       .where("community_tags.nid = ? AND (name LIKE ? OR name LIKE ?)", self.id, tagname, tagname.gsub('*', '%'))
    end
    tags
  end

  def has_tag_without_aliasing(tagname)
    tags = self.get_matching_tags_without_aliasing(tagname)
    tids = tags.collect(&:tid).uniq
    NodeCommunityTag.where('nid IN (?) AND tid IN (?)', self.id, tids).length > 0
  end

  # has it been tagged with "list:foo" where "foo" is the name of a Google Group?
  def mailing_list
    begin
      Rails.cache.fetch("feed-"+self.id.to_s+"-"+(self.updated_at.to_i/300).to_i.to_s) do
        RSS::Parser.parse(open('https://groups.google.com/group/'+self.power_tag('list')+'/feed/rss_v2_0_topics.xml').read, false).items
      end
    rescue
      return []
    end
  end

  # End of tag-related methods

  # used in typeahead autocomplete search results
  def icon
   icon = "file" if self.type == "note"
   icon = "book" if self.type == "page"
   icon = "map-marker" if self.type == "map"
   icon = "flag" if self.has_tag('chapter')
   icon = "wrench" if self.type == "tool"
   icon = "question-circle" if self.has_power_tag('question')
   icon
  end

  def tags
    self.tag
  end

  def community_tags
    self.node_community_tag
  end

  def tagnames
    self.tags.collect(&:name)
  end

  # increment view count
  def view
    NodeCounter.new({:nid => self.id}).save if self.node_counter.nil?
    self.node_counter.totalcount += 1
    self.node_counter.save
  end

  # view count
  def totalcount
    NodeCounter.new({:nid => self.id}).save if self.node_counter.nil?
    self.node_counter.totalcount
  end

  def edit_path
    if self.type == "page" || self.type == "tool" || self.type == "place"
      path = "/wiki/edit/" + self.path.split("/").last
    else
      path = "/notes/edit/"+self.id.to_s
    end
    path
  end

  def self.find_root_by_slug(title)
    Node.where(path: ["/#{title}"]).first
  end

  def map
    # This fires off a query that orders by vid DESC
    # and is quicker than doing .order(vid: :DESC) for some reason.
    self.content_type_map.last
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
    Node.where('uid = ? and nid > ? and type = "note"', self.author.uid, self.nid)
              .order('nid')
              .first
  end

  def prev_by_author
    Node.where('uid = ? and nid < ? and type = "note"', self.author.uid, self.nid)
              .order('nid desc')
              .first
  end

  # ============================================
  # Automated constructors for associated models

  def add_comment(params = {})
    if self.comments.length > 0
      thread = self.comments.last.next_thread
    else
      thread = "01/"
    end
    c = Comment.new({
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
    NodeRevision.new({
      :nid => params[:nid],
      :uid => params[:uid],
      :title => params[:title],
      :body => params[:body]
    })
  end

  # handle creating a new note with attached revision and main image
  # this is kind of egregiously bad... must revise after
  # researching simultaneous creation of associated records
  def self.new_note(params)
    saved = false
    author = Users.find(params[:uid])
    node = Node.new({
      uid:     author.uid,
      title:   params[:title],
      comment: 2,
      type:    "note"
    })
    node.status = 4 if author.first_time_poster
    if node.valid? # is this not triggering title uniqueness validation?
      saved = true
      revision = false
      ActiveRecord::Base.transaction do
        node.save!
        revision = node.new_revision({
          nid:   node.id,
          uid:   author.uid,
          title: params[:title],
          body:  params[:body]
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
          node.notify
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
    node = Node.new({
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
          #node.notify # we don't yet notify of wiki page creations
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
    node = Node.new({
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

  def add_barnstar(tagname,giver)
    self.add_tag(tagname,giver.user)
    CommentMailer.notify_barnstar(giver,self)
  end

  def add_tag(tagname,user)
    tagname = tagname.downcase
    unless self.has_tag_without_aliasing(tagname)
      saved = false
      tag = Tag.find_by_name(tagname) || Tag.new({
        vid:         3, # vocabulary id; 1
        name:        tagname,
        description: "",
        weight:      0
      })
      ActiveRecord::Base.transaction do
        if tag.valid?
          tag.save!
          node_tag = NodeCommunityTag.new({
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

  def mentioned_users
    usernames = self.body.scan(Callouts.const_get(:FINDER))
    User.find_all_by_username(usernames.map {|m| m[1] }).uniq
  end

  def self.find_notes(author, date, title)
    Node.where(path: "/notes/#{author}/#{date}/#{title}").first
  end

  def self.find_map(name, date)
    Node.where(path: "/map/#{name}/#{date}").first
  end

  def self.find_wiki(title)
    Node.where(path: ["/#{title}", "/tool/#{title}", "/wiki/#{title}", "/place/#{title}"]).first
  end

  def self.research_notes
    nids = Node.where(type: 'note')
                     .joins(:tag)
                     .where('term_data.name LIKE ?', 'question:%')
                     .group('node.nid')
                     .collect(&:nid)
    notes = Node.where(type: 'note')
                      .where('node.nid NOT IN (?)', nids)
  end

  def self.questions
    questions = Node.where(type: 'note')
                          .joins(:tag)
                          .where('term_data.name LIKE ?', 'question:%')
                          .group('node.nid')
  end

  def body_preview
    self.try(:latest).body_preview
  end

  def self.activities(tagname)
    Node.where(status: 1, type: 'note')
              .includes(:node_revision, :tag)
              .where('term_data.name LIKE ?', "activity:#{tagname}")
  end

  def self.upgrades(tagname)
    Node.where(status: 1, type: 'note')
              .includes(:node_revision, :tag)
              .where('term_data.name LIKE ?', "upgrade:#{tagname}")
  end

end
