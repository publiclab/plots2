class DrupalUsers < ActiveRecord::Base
  attr_accessible :title, :body, :name, :pass, :mail, :mode, :sort, :threshold, :theme, :signature, :signature_format, :created, :access, :login, :status, :timezone, :language, :picture, :init, :data, :timezone_id, :timezone_name

  ## User status can be:
  #  0: banned
  #  1: normal
  #  5: moderated

  self.table_name = 'users'
  self.primary_key = 'uid'

  has_many :node, :foreign_key => 'uid'
  has_many :drupal_profile_values, :foreign_key => 'uid'
  has_many :node_selections, :foreign_key => :user_id
  has_many :answers, :foreign_key => :uid
  has_many :answer_selections, :foreign_key => :user_id
  has_many :comments, :foreign_key => 'uid'
  has_one :location_tag, :foreign_key => 'uid', :dependent => :destroy

  searchable :if => proc { |user| user.status == 1 } do
    string :name
    string :mail
    string :status
  end

  def user
    User.find_by_username self.name
  end

  def username
    self.name
  end

  def using_new_site?
    !User.find_by_username(self.name).nil?
  end

  # Rails-style adaptors:

  def created_at
    Time.at(self.created)
  end

  # End rails-style adaptors

  def role
    self.user.role if self.user
  end

  def moderate
    self.status = 5
    self.save
    # user is logged out next time they access current_user in a controller; see application controller
    self
  end

  def unmoderate
    self.status = 1
    self.save
    self
  end

  def ban
    self.status = 0
    decrease_likes_banned
    self.save
    # user is logged out next time they access current_user in a controller; see application controller
    self
  end

  def unban
    self.status = 1
    increase_likes_unbanned
    self.save
    self
  end

  def email
    self.mail
  end

  def first_time_poster
    self.user.first_time_poster
  end

  def likes
    NodeSelection.find(:all, :conditions => {:user_id => self.uid, :liking => true})
  end

  def like_count
    NodeSelection.count(:all, :conditions => {:user_id => self.uid, :liking => true})
  end

  def liked_notes
    Node.includes(:node_selections)
              .where("type = 'note' AND node_selections.liking = ? AND node_selections.user_id = ? AND node.status = 1", true, self.uid)
              .order('node_selections.nid DESC')
  end

  def liked_pages
    NodeSelection.find(:all, :conditions => ["status = 1 AND user_id = ? AND liking = ? AND (node.type = 'page' OR node.type = 'tool' OR node.type = 'place')",self.uid, true], :include => :node).collect(&:node).reverse
  end

  # last node
  def last
    Node.limit(1)
              .where(uid: self.uid)
              .order('changed DESC')
              .first
  end

  def profile_values
    self.drupal_profile_values
  end

  def set_bio(text)
    bio = DrupalProfileValue.find_by_uid(self.uid, :conditions => {:fid => 7})
    bio = DrupalProfileValue.new({:fid => 7, :uid => self.uid}) if bio.nil?
    bio.value = text
    bio.save!
  end

  def bio
    bio = DrupalProfileValue.find_by_uid(self.uid, :conditions => {:fid => 7})
    if bio
      bio.value || ""
    else
      ""
    end
  end

  def notes
    self.user.notes
  end

  def note_count
    Node.count(:all,:conditions => {:status => 1, :uid => self.uid, :type => "note"})
  end

  def node_count
    Node.count(:all,:conditions => {:status => 1, :uid => self.uid}) + DrupalNodeRevision.count(:all, :conditions => {:uid => self.uid})
  end

  # accepts array of tag names (strings)
  def notes_for_tags(tagnames)
    all_nodes = Node.find(:all,:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => self.uid})
    node_ids = []
    all_nodes.each do |node|
      node.tags.each do |tag|
        tagnames.each do |tagname|
          node_ids << node.nid if tag.name == tagname
        end
      end
    end
    Node.find(node_ids.uniq, :order => "nid DESC")
  end

  def tags(limit = 10)
    Tag.find :all, :conditions => ['name in (?)',self.tagnames], :limit => limit
  end

  def tagnames(limit = 20,defaults = true)
    tagnames = []
    Node.find(:all,:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => self.uid}, :limit => limit).each do |node|
      tagnames += node.tags.collect(&:name)
    end
    tagnames += ["balloon-mapping","spectrometer","near-infrared-camera","thermal-photography","newsletter"] if tagnames.length == 0 && defaults
    tagnames.uniq
  end

  def tag_counts
    tags = {}
    Node.find(:all,:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => self.uid}, :limit => 20).each do |node|
      node.tags.each do |tag|
        if tags[tag.name]
          tags[tag.name] += 1
        else
          tags[tag.name] = 1
        end
      end
    end
    tags
  end

  def migrate
    u = User.new({
      :username => self.name,
      :id => self.uid,
      :email => self.mail,
      :openid_identifier => "//old.publiclab.org/user/"+self.uid.to_s+"/identity"
    })
    u.persistence_token = rand(100000000)
    if u.save(:validate => false) # <= because validations checks for conflict with existing drupal_user.name
      key = u.generate_reset_key
      PasswordResetMailer.reset_notify(u,key)
      return true
    else
      return false
    end
  end

  def self.find_by_name_and_status(name, status)
    where(name: name, status: status)
  end

  private

  def decrease_likes_banned
    node_selections.each do |node|
      node.node.cached_likes = node.node.cached_likes - 1
      node.node.save!
    end
  end

  def increase_likes_unbanned
    node_selections.each do |node|
      node.node.cached_likes = node.node.cached_likes + 1
      node.node.save!
    end
  end
end
