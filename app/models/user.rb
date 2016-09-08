class UniqueUsernameValidator < ActiveModel::Validator
  def validate(record)
    if DrupalUsers.find_by_name(record.username) && record.openid_identifier.nil?
      record.errors[:base] << "That username is already taken. If this is your username, you can simply log in to this site."  
    end
  end
end

class User < ActiveRecord::Base
  self.table_name = 'rusers'
  attr_accessible :username, :email, :password, :password_confirmation, :openid_identifier, :key, :photo, :photo_file_name, :location_privacy

  acts_as_authentic do |c|
    c.openid_required_fields = [:nickname, :email]
  end

  has_attached_file :photo, :styles => { :thumb => "200x200#", :medium => "500x500#", :large => "800x800#" },
                  :url  => "/system/profile/photos/:id/:style/:basename.:extension"
                  #:path => ":rails_root/public/system/images/photos/:id/:style/:basename.:extension"
  do_not_validate_attachment_file_type :photo_file_name
  #validates_attachment_content_type :photo_file_name, :content_type => %w(image/jpeg image/jpg image/png)

  # this doesn't work... we should have a uid field on User
  #has_one :drupal_users, :conditions => proc { ["drupal_users.name =  ?", self.username] }
  has_many :images, :foreign_key => :uid
  has_many :drupal_node, :foreign_key => 'uid'
  has_many :user_tags, :foreign_key => 'uid', :dependent => :destroy
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :following_users, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  validates_with UniqueUsernameValidator, :on => :create
  validates_format_of :username, :with => /^[A-Za-z\d_\-]+$/

  before_create :create_drupal_user
  after_destroy :destroy_drupal_user

  def create_drupal_user
    if self.drupal_user.nil?
      drupal_user = DrupalUsers.new({
        :name => self.username,
        :pass => rand(100000000000000000000),
        :mail => self.email,
        :mode => 0,
        :sort => 0,
        :threshold => 0,
        :theme => "",
        :signature => "",
        :signature_format => 0,
        :created => DateTime.now.to_i,
        :access => DateTime.now.to_i,
        :login => DateTime.now.to_i,
        :status => 1,
        :timezone => nil,
        :language => "",
        :picture => "",
        :init => "",
        :data => nil,
        :timezone_id => 0,
        :timezone_name => ""
      })
      drupal_user.save!
      self.id = drupal_user.uid
    else
      self.id = DrupalUsers.find_by_name(self.username).uid
    end
  end

  def destroy_drupal_user
    self.drupal_user.destroy
  end
 
  # this is ridiculous. We need to store uid in this model.
  # ...migration is in progress. start getting rid of these calls... 
  def drupal_user
    DrupalUsers.find_by_name(self.username)
  end

  def notes
    DrupalNode.where(uid: self.uid)
              .where(type: 'note')
              .order("created DESC")
  end

  def generate_reset_key
    # invent a key and save it
    key = ""
    20.times do
      key += [*'a'..'z'].sample
    end
    self.reset_key = key
    key
  end

  def bio
    self.drupal_user.bio
  end

  def uid
    self.drupal_user.uid
  end

  def lat
    self.drupal_user.lat
  end

  def lon
    self.drupal_user.lon
  end

  # we can revise/improve this for m2m later... 
  def has_role(r)
    self.role == r
  end

  def subscriptions(type = :tag)
    if type == :tag
      TagSelection.find_all_by_user_id self.uid, :conditions => {:following => true}
    end
  end

  def following(tagname)
    tids = DrupalTag.find(:all, :conditions => {:name => tagname}).collect(&:tid)
    TagSelection.find(:all, :conditions => {:following => true,:tid => tids, :user_id => self.uid}).length > 0
  end

  def mapknitter_maps
    # http://mapknitter.org/feeds/author/hagitkeysar
    #begin
    #  RSS::Parser.parse(open('http://mapknitter.org/feeds/author/'+self.username).read, false).items
    #rescue
    #  []
    #end
    []
  end

  def add_to_lists(lists)
    lists.each do |list|
      WelcomeMailer.add_to_list(self,list)
    end
  end

  def weekly_note_tally(span = 52)
    weeks = {}
    (0..span).each do |week|
      weeks[span-week] = DrupalNode.count :all, :select => :created, :conditions => {:uid => self.drupal_user.uid, :type => 'note', :status => 1, :created => Time.now.to_i-week.weeks.to_i..Time.now.to_i-(week-1).weeks.to_i}
    end
    weeks
  end

  def weekly_comment_tally(span = 52)
    weeks = {}
    (0..span).each do |week|
      weeks[span-week] = DrupalComment.count :all, :select => :timestamp, :conditions => {:uid => self.drupal_user.uid, :status => 1, :timestamp => Time.now.to_i-week.weeks.to_i..Time.now.to_i-(week-1).weeks.to_i}
    end
    weeks
  end

  def note_streak(span = 365)
    days = {}
    streak = 0
    note_count = 0
    (0..span).each do |day|
      days[day] = DrupalNode.count :all, :select => :created, :conditions => {:uid => self.drupal_user.uid, :type => 'note', :status => 1, :created => Time.now.midnight.to_i-day.days.to_i..Time.now.midnight.to_i-(day-1).days.to_i}
      break if days[day] == 0
      streak+=1
      note_count+=days[day]
    end
    [streak, note_count]
  end

  def wiki_edit_streak(span = 365)
    days = {}
    streak = 0
    wiki_edit_count = 0
    (0..span).each do |day|
      days[day] = DrupalNodeRevision.joins(:drupal_node).where(:uid => self.drupal_user.uid, :status => 1, :timestamp => Time.now.midnight.to_i-day.days.to_i..Time.now.midnight.to_i-(day-1).days.to_i).where("node.type != ?", 'note').count 
      break if days[day] == 0
      streak+=1
      wiki_edit_count+=days[day]
    end
    [streak, wiki_edit_count]
  end

  def comment_streak(span = 365)
    days = {}
    streak = 0
    comment_count = 0
    (0..span).each do |day|
      days[day] = DrupalComment.count :all, :select => :timestamp, :conditions => {:uid => self.drupal_user.uid, :status => 1, :timestamp => Time.now.midnight.to_i-day.days.to_i..Time.now.midnight.to_i-(day-1).days.to_i}
      break if days[day] == 0
      streak+=1
      comment_count+=days[day]
    end
    [streak, comment_count]
  end

  def streak(span = 365)
    note_streak = self.note_streak(span)
    wiki_edit_streak = self.wiki_edit_streak(span)
    comment_streak = self.comment_streak(span)
    streak_count = [note_streak[1], wiki_edit_streak[1], comment_streak[1]]
    streak = [note_streak[0], wiki_edit_streak[0], comment_streak[0]]
    [streak.max, streak_count]
  end

  def barnstars
    DrupalNodeCommunityTag.includes(:drupal_node,:drupal_tag).where("type = ? AND term_data.name LIKE ? AND node.uid = ?",'note','barnstar:%',self.uid)
  end

  def photo_path(size = :medium)
    if Rails.env == "production"
      '//i.publiclab.org'+self.photo.url(size)
    else
      self.photo.url(size).gsub('//i.publiclab.org','')
    end
  end

  def first_time_poster
    self.notes.where(status: 1).count == 0
  end

  def follow(other_user)
    self.active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    self.active_relationships.find_by_followed_id(other_user.id).destroy
  end

  def following?(other_user)
    following_users.include?(other_user)
  end

  def profile_image
    if self.photo_file_name
      puts self.photo_path(:thumb)
      self.photo_path(:thumb)
    else
      "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(self.email)}"
    end
  end

  private

  def map_openid_registration(registration)
    self.email = registration["email"] if email.blank?
    self.username = registration["nickname"] if username.blank?
  end

end
