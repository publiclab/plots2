class UniqueUsernameValidator < ActiveModel::Validator
  def validate(record)
    if DrupalUsers.find_by_name(record.username) && record.openid_identifier.nil?
      record.errors[:base] << 'That username is already taken. If this is your username, you can simply log in to this site.'
    end
  end
end

class User < ActiveRecord::Base
  self.table_name = 'rusers'
  attr_accessible :username, :email, :password, :password_confirmation, :openid_identifier, :key, :photo, :photo_file_name, :bio
  alias_attribute :name, :username

  include SolrToggle
  searchable if: :shouldIndexSolr do
    text :username, :email
  end

  acts_as_authentic do |c|
    c.openid_required_fields = %i[nickname email]
    c.validates_format_of_email_field_options = { with: /@/ }
  end

  has_attached_file :photo, styles: { thumb: '200x200#', medium: '500x500#', large: '800x800#' },
                            url: '/system/profile/photos/:id/:style/:basename.:extension'
  #:path => ":rails_root/public/system/images/photos/:id/:style/:basename.:extension"
  do_not_validate_attachment_file_type :photo_file_name
  # validates_attachment_content_type :photo_file_name, :content_type => %w(image/jpeg image/jpg image/png)

  # this doesn't work... we should have a uid field on User
  # has_one :drupal_users, :conditions => proc { ["drupal_users.name =  ?", self.username] }
  has_many :images, foreign_key: :uid
  has_many :node, foreign_key: 'uid'
  has_many :user_tags, foreign_key: 'uid', dependent: :destroy
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :following_users, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  validates_with UniqueUsernameValidator, on: :create
  validates_format_of :username, with: /^[A-Za-z\d_\-]+$/
  validates_format_of :email, with: /@/

  before_create :create_drupal_user
  before_save :set_token
  after_destroy :destroy_drupal_user

  def create_drupal_user
    self.bio ||= ''
    if drupal_user.nil?
      drupal_user = DrupalUsers.new(name: username,
                                    pass: rand(100_000_000_000_000_000_000),
                                    mail: email,
                                    mode: 0,
                                    sort: 0,
                                    threshold: 0,
                                    theme: '',
                                    signature: '',
                                    signature_format: 0,
                                    created: DateTime.now.to_i,
                                    access: DateTime.now.to_i,
                                    login: DateTime.now.to_i,
                                    status: 1,
                                    timezone: nil,
                                    language: '',
                                    picture: '',
                                    init: '',
                                    data: nil,
                                    timezone_id: 0,
                                    timezone_name: '')
      drupal_user.save!
      self.id = drupal_user.uid
    else
      self.id = DrupalUsers.find_by_name(username).uid
    end
  end

  def destroy_drupal_user
    drupal_user.destroy
  end

  def set_token
    self.token = SecureRandom.uuid if self.token.nil?
  end

  # this is ridiculous. We need to store uid in this model.
  # ...migration is in progress. start getting rid of these calls...
  def drupal_user
    DrupalUsers.find_by_name(username)
  end

  def notes
    Node.where(uid: uid)
        .where(type: 'note')
        .order('created DESC')
  end

  def generate_reset_key
    # invent a key and save it
    key = ''
    20.times do
      key += [*'a'..'z'].sample
    end
    self.reset_key = key
    key
  end

  def uid
    drupal_user.uid
  end

  def lat
    drupal_user.lat
  end

  def lon
    drupal_user.lon
  end

  # we can revise/improve this for m2m later...
  def has_role(r)
    role == r
  end

  def tags(limit = 10)
    Tag.find :all, conditions: ['name in (?)', tagnames], limit: limit
  end

  def tagnames(limit = 20, defaults = true)
    tagnames = []
    Node.find(:all, order: 'nid DESC', conditions: { type: 'note', status: 1, uid: self.id }, limit: limit).each do |node|
      tagnames += node.tags.collect(&:name)
    end
    tagnames += ['balloon-mapping', 'spectrometer', 'near-infrared-camera', 'thermal-photography', 'newsletter'] if tagnames.empty? && defaults
    tagnames.uniq
  end

  def has_tag(tagname)
    user_tags.collect(&:value).include?(tagname)
  end

  def subscriptions(type = :tag)
    if type == :tag
      TagSelection.find_all_by_user_id uid, conditions: { following: true }
    end
  end

  def following(tagname)
    tids = Tag.where(name: tagname).collect(&:tid)
    !TagSelection.where(following: true, tid: tids, user_id: uid).empty?
  end

  def add_to_lists(lists)
    lists.each do |list|
      WelcomeMailer.add_to_list(self, list)
    end
  end

  def weekly_note_tally(span = 52)
    weeks = {}
    (0..span).each do |week|
      weeks[span - week] = Node.select(:created)
                               .where( uid: drupal_user.uid,
                                       type: 'note',
                                       status: 1,
                                       created: Time.now.to_i - week.weeks.to_i..Time.now.to_i - (week - 1).weeks.to_i)
                               .count
    end
    weeks
  end

  def weekly_comment_tally(span = 52)
    weeks = {}
    (0..span).each do |week|
      weeks[span - week] = Comment.select(:timestamp)
                                  .where( uid: drupal_user.uid,
                                          status: 1,
                                          timestamp: Time.now.to_i - week.weeks.to_i..Time.now.to_i - (week - 1).weeks.to_i)
                                  .count
    end
    weeks
  end

  def note_streak(span = 365)
    days = {}
    streak = 0
    note_count = 0
    (0..span).each do |day|
      days[day] = Node.select(:created)
                      .where( uid: drupal_user.uid,
                              type: 'note',
                              status: 1,
                              created: Time.now.midnight.to_i - day.days.to_i..Time.now.midnight.to_i - (day - 1).days.to_i)
                      .count
      break if days[day] == 0
      streak += 1
      note_count += days[day]
    end
    [streak, note_count]
  end

  def wiki_edit_streak(span = 365)
    days = {}
    streak = 0
    wiki_edit_count = 0
    (0..span).each do |day|
      days[day] = Revision.joins(:node)
                          .where( uid: drupal_user.uid,
                                  status: 1,
                                  timestamp: Time.now.midnight.to_i - day.days.to_i..Time.now.midnight.to_i - (day - 1).days.to_i)
                          .where('node.type != ?', 'note')
                          .count
      break if days[day] == 0
      streak += 1
      wiki_edit_count += days[day]
    end
    [streak, wiki_edit_count]
  end

  def comment_streak(span = 365)
    days = {}
    streak = 0
    comment_count = 0
    (0..span).each do |day|
      days[day] = Comment.select(:timestamp)
                         .where( uid: drupal_user.uid,
                                 status: 1,
                                 timestamp: Time.now.midnight.to_i - day.days.to_i..Time.now.midnight.to_i - (day - 1).days.to_i)
                         .count
      break if days[day] == 0
      streak += 1
      comment_count += days[day]
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
    NodeTag.includes(:node, :tag).where('type = ? AND term_data.name LIKE ? AND node.uid = ?', 'note', 'barnstar:%', uid)
  end

  def photo_path(size = :medium)
    photo.url(size)
  end

  def first_time_poster
    notes.where(status: 1).count == 0
  end

  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by_followed_id(other_user.id).destroy
  end

  def following?(other_user)
    following_users.include?(other_user)
  end

  def profile_image
    if photo_file_name
      puts photo_path(:thumb)
      photo_path(:thumb)
    else
      "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}"
    end
  end

  def questions
    Node.questions.where(status: 1, uid: id)
  end

  def content_followed_in_past_period(time_period)
    self.node.where("created >= #{time_period.to_i}  AND changed >= #{time_period.to_i}")
  end

  private

  def map_openid_registration(registration)
    self.email = registration['email'] if email.blank?
    self.username = registration['nickname'] if username.blank?
  end

  def self.find_by_username_case_insensitive(username)
    User.where('lower(username) = ?', username.downcase).first
  end
end
