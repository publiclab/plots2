class DrupalUsers < ActiveRecord::Base
  attr_accessible :title, :body, :name, :pass, :mail, :mode, :sort, :threshold, :theme, :signature, :signature_format, :created, :access, :login, :status, :timezone, :language, :picture, :init, :data, :timezone_id, :timezone_name

  self.table_name = 'users'
  self.primary_key = 'uid'

  has_many :drupal_node, :foreign_key => 'uid'
  has_many :drupal_profile_values, :foreign_key => 'uid'
  has_many :drupal_profile_values, :foreign_key => 'uid'
  has_many :node_selections, :foreign_key => :user_id
  has_many :answers, :foreign_key => :uid

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

  def unban
    self.status = 1
    self.save
    self
  end

  def ban
    self.status = 0
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
    DrupalNode.includes(:node_selections).where("type = 'note' AND node_selections.liking = true AND node_selections.user_id = ? AND node.status = 1", self.uid).order('node_selections.nid DESC')
  end

  def liked_pages
    NodeSelection.find(:all, :conditions => ["status = 1 AND user_id = ? AND liking = true AND (node.type = 'page' OR node.type = 'tool' OR node.type = 'place')",self.uid], :include => :drupal_node).collect(&:node).reverse
  end

  # last node
  def last
    DrupalNode.limit(1).where(uid:self.uid).order('changed DESC').first
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
    DrupalNode.count(:all,:conditions => {:status => 1, :uid => self.uid, :type => "note"})
  end

  def node_count
    DrupalNode.count(:all,:conditions => {:status => 1, :uid => self.uid}) + DrupalNodeRevision.count(:all, :conditions => {:uid => self.uid})
  end

  # accepts array of tag names (strings)
  def notes_for_tags(tagnames)
    all_nodes = DrupalNode.find(:all,:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => self.uid})
    node_ids = []
    all_nodes.each do |node|
      node.tags.each do |tag|
        tagnames.each do |tagname|
          node_ids << node.nid if tag.name == tagname
        end
      end
    end
    DrupalNode.find(node_ids.uniq, :order => "nid DESC")
  end

  def tags(limit = 10)
    DrupalTag.find :all, :conditions => ['name in (?)',self.tagnames], :limit => limit
  end

  def tagnames(limit = 20,defaults = true)
    tagnames = []
    DrupalNode.find(:all,:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => self.uid}, :limit => limit).each do |node|
      tagnames += node.tags.collect(&:name)
    end
    tagnames += ["balloon-mapping","spectrometer","near-infrared-camera","thermal-photography","newsletter"] if tagnames.length == 0 && defaults
    tagnames.uniq
  end

  def tag_counts
    tags = {}
    DrupalNode.find(:all,:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => self.uid}, :limit => 20).each do |node|
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

end
