class UniqueUsernameValidator < ActiveModel::Validator
  def validate(record)
    if User.find_by(username: record.username) && record.openid_identifier.nil?
      record.errors[:base] << 'That username is already taken. If this is your username, you can simply log in to this site.'
    end
  end
end

# Overwrites authlogic username regex to allow one character usernames
Authlogic::Regex::LOGIN = /\A[A-Za-z\d_\-]*\z/

class User < ActiveRecord::Base
  extend Utils
  include Statistics
  extend RawStats
  self.table_name = 'rusers'
  alias_attribute :name, :username

  module Status
    VALUES = [
      NORMAL = 1,   # Usage: Status::NORMAL
      BANNED = 0,   # Usage: Status::BANNED
      MODERATED = 5 # Usage: Status::MODERATED
    ].freeze
  end

  module Frequency
    VALUES = [
      DAILY = 0,
      WEEKLY = 1
    ].freeze
  end

  attr_readonly :username

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::Sha512
    c.validates_format_of_login_field_options = { with: Authlogic::Regex::LOGIN, message: I18n.t('error_messages.login_invalid', default: "can only consist of alphabets, numbers, underscore '_', and hyphen '-'.") }
  end

  has_attached_file :photo, styles: { thumb: '200x200#', medium: '500x500#', large: '800x800#' },
                                    url: '/system/profile/photos/:id/:style/:basename.:extension'
  #:path => ":rails_root/public/system/images/photos/:id/:style/:basename.:extension"

  do_not_validate_attachment_file_type :photo_file_name
  # validates_attachment_content_type :photo_file_name, :content_type => %w(image/jpeg image/jpg image/png)

  has_many :images, foreign_key: :uid
  has_many :node, foreign_key: 'uid'
  has_many :csvfiles, foreign_key: :uid
  has_many :node_selections, foreign_key: :user_id
  has_many :revision, foreign_key: 'uid'
  has_many :user_tags, foreign_key: 'uid', dependent: :destroy
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :following_users, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :likes
  has_many :answers, foreign_key: :uid
  has_many :answer_selections, foreign_key: :user_id
  has_many :revisions, through: :node
  has_many :comments, foreign_key: :uid

  validates_with UniqueUsernameValidator, on: :create

  before_save :set_token

  scope :past_week, -> { where("created_at > ?", 7.days.ago) }
  scope :past_month, -> { where("created_at > ?", 1.month.ago) }

  def is_new_contributor?
    Node.where(uid: id).size === 1 && Node.where(uid: id).first.created_at > 1.month.ago
  end

  def new_contributor
    return "<a href='/tag/first-time-poster' class='badge badge-success font-italic'>new contributor</a>".html_safe if is_new_contributor?
  end

  def set_token
    self.token = SecureRandom.uuid if token.nil?
  end

  def nodes
    node
  end

  def notes
    Node.where(uid: uid)
    .where(type: 'note')
    .order('created DESC')
  end

  def coauthored_notes
    coauthored_tag = "with:" + name.downcase
    Node.where(status: 1, type: "note")
    .includes(:revision, :tag)
    .references(:term_data, :node_revisions)
    .where('term_data.name = ? OR term_data.parent = ?', coauthored_tag.to_s, coauthored_tag.to_s)
  end

  def generate_reset_key
    key = [*'a'..'z'].sample(20).join

    update_attribute(:reset_key, key)

    key
  end

  def uid
    id
  end

  def title
    username
  end

  def path
    "/profile/#{username}"
  end

  def lat
    get_value_of_power_tag('lat')
  end

  def lon
    get_value_of_power_tag('lon')
  end

  # we can revise/improve this for m2m later...
  def has_role(some_role)
    role == some_role
  end

  def admin?
    role == 'admin'
  end

  def moderator?
    role == 'moderator'
  end

  def can_moderate?
    admin? || moderator?
  end

  def is_coauthor?(node)
    id == node.author.id || node.has_tag("with:#{username}")
  end

  def tags(limit = 10)
    Tag.where('name in (?)', tagnames).limit(limit)
  end

  def normal_tags
	tags.select{ |tag| ! tag.name.include?(':') }
  end

  def tagnames(limit = 20, defaults = true)
    tagnames = []
    Node.includes(:tag).order('nid DESC').where(type: 'note', status: 1, uid: id).limit(limit).each do |node|
      tagnames += node.tags.collect(&:name)
    end
    tagnames.uniq
  end

  def has_tag(tagname)
    user_tags.collect(&:value).include?(tagname)
  end

  # power tags have "key:value" format, and should be searched with a "key:*" wildcard
  def has_power_tag(key)
    user_tags.where('value LIKE ?', key + ':%').exists?
  end

  def get_value_of_power_tag(key)
    tname = user_tags.where('value LIKE ?', key + ':%')
    tvalue = tname.first.name.partition(':').last if tname.present?
    tvalue
  end

  def blurred?
    has_power_tag("location") && get_value_of_power_tag("location") == 'blurred'
  end

  def get_last_value_of_power_tag(key)
    tname = user_tags.where('value LIKE ?', key + ':%')
    tvalue = tname.last.name.partition(':').last
    tvalue
  end

  def subscriptions(type = :tag)
    if type == :tag
      TagSelection.where(user_id: uid,
       following: true)
    end
  end

  def following(tagname)
    tids = Tag.where(name: tagname).collect(&:tid)
    !TagSelection.where(following: true, tid: tids, user_id: uid).empty?
  end

  def add_to_lists(lists)
    lists.each do |list|
      WelcomeMailer.add_to_list(self, list).deliver_now
    end
  end

  def barnstars
    NodeTag.includes(:node, :tag)
    .references(:term_data)
    .where('type = ? AND term_data.name LIKE ? AND node.uid = ?', 'note', 'barnstar:%', uid)
  end

  def photo_path(size = :medium)
    photo.url(size)
  end

  def first_time_poster
    notes.where(status: 1).size.zero?
  end

  def first_time_commenter
    Comment.where(status: 1, uid: uid).size.zero?
  end

  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.where(followed_id: other_user.id).first.destroy
  end

  def following?(other_user)
    following_users.include?(other_user)
  end

  def profile_image(size = :thumb)
    if photo_file_name
      photo_path(size)
    else
      "https://www.gravatar.com/avatar/#{OpenSSL::Digest::MD5.hexdigest(email)}"
    end
  end

  def questions
    Node.questions.where(status: 1, uid: id)
  end

  def content_followed_in_period(start_time, end_time, node_type = 'note', include_revisions = false)
    tagnames = TagSelection.where(following: true, user_id: uid)
    node_ids = []
    tagnames.each do |tagname|
      node_ids += NodeTag.where(tid: tagname.tid).collect(&:nid)
    end

    range = "(created >= #{start_time.to_i} AND created <= #{end_time.to_i})"
    range += " OR (timestamp >= #{start_time.to_i}  AND timestamp <= #{end_time.to_i})" if include_revisions

    Node.where(nid: node_ids)
    .includes(:revision, :tag)
    .references(:node_revision)
    .where('node.status = 1')
    .where(type: node_type)
    .where(range)
    .order('node_revisions.timestamp DESC')
    .distinct
  end

  def unmoderated_in_period(start_time, end_time)
    range = "(created >= #{start_time.to_i} AND created <= #{end_time.to_i})"
    Node.where('node.status = 4')
        .where(type: 'note')
        .where(range)
        .order('created DESC')
        .distinct
  end

  def social_link(site)
    return nil unless has_power_tag(site)

    user_name = get_last_value_of_power_tag(site)
    "https://#{site}.com/#{user_name}"
  end

  def moderate
    self.status = Status::MODERATED
    save
    # user is logged out next time they access current_user in a controller; see application controller
    self
  end

  def unmoderate
    self.status = Status::NORMAL
    save
    self
  end

  def ban
    decrease_likes_banned
    self.status = Status::BANNED
    save
    # user is logged out next time they access current_user in a controller; see application controller
    self
  end

  def unban
    increase_likes_unbanned
    self.status = Status::NORMAL
    save
    self
  end

  def self.send_browser_notification(users_ids, notification)
    users_ids.each do |uid|
      if UserTag.where(value: 'notifications:all', uid: uid).any?
        ActionCable.server.broadcast "users:notification:#{uid}", notification: notification
      end
    end
  end

  def banned?
    status == Status::BANNED
  end

  def note_count
    Node.where(status: 1, uid: uid, type: 'note').size
  end

  def node_count
    Node.where(status: 1, uid: uid).size + Revision.where(uid: uid).size
  end

  def liked_notes
    Node.includes(:node_selections)
    .references(:node_selections)
    .where("type = 'note' AND \
      node_selections.liking = ? \
      AND node_selections.user_id = ? \
      AND node.status = 1", true, id)
    .order('node_selections.nid DESC')
  end

  def liked_pages
    nids = NodeSelection.where(user_id: uid, liking: true)
                        .collect(&:nid)

    Node.where(nid: nids)
        .where(type: 'page')
        .order('nid DESC')
  end

  def send_digest_email
    if has_tag('digest:daily')
      @nodes = content_followed_in_period(1.day.ago, Time.current)
      @frequency = Frequency::DAILY
    else
      @nodes = content_followed_in_period(1.week.ago, Time.current)
      @frequency = Frequency::WEEKLY
    end

    if @nodes.size.positive?
      SubscriptionMailer.send_digest(id, @nodes, @frequency).deliver_now
    end
  end

  def send_digest_email_spam
    if has_tag('digest:weekly:spam')
      @frequency_digest = Frequency::WEEKLY
      @nodes_unmoderated = unmoderated_in_period(1.week.ago, Time.current)
    elsif has_tag('digest:daily:spam')
      @frequency_digest = Frequency::DAILY
      @nodes_unmoderated = unmoderated_in_period(1.day.ago, Time.current)
    end
    if @nodes_unmoderated.size.positive?
      AdminMailer.send_digest_spam(@nodes_unmoderated, @frequency_digest).deliver_now
    end
 end

  def tag_counts
    tags = {}
    Node.order('nid DESC').where(type: 'note', status: 1, uid: id).limit(20).each do |node|
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

  def generate_token
    user_id_and_time = { id: id, timestamp: Time.now }
    User.encrypt(user_id_and_time)
  end

  class << self
    def search(query)
      User.where('MATCH(bio, username) AGAINST(? IN BOOLEAN MODE)', "#{query}*")
    end

    def search_by_username(query)
      User.where('MATCH(username) AGAINST(? IN BOOLEAN MODE)', "#{query}*")
    end

    def validate_token(token)
      begin
        decrypted_data = User.decrypt(token)
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        return 0
      end

      if (Time.now - decrypted_data[:timestamp]) / 1.hour > 24.0
        return 0
      else
        return decrypted_data[:id]
      end
    end

    def find_by_username_case_insensitive(username)
      User.where('lower(username) = ?', username.downcase).first
    end

    # all users who've posted a node, comment, or answer in the given period
    def contributor_count_for(start_time, end_time)
      notes = Node.where(type: 'note', status: 1, created: start_time.to_i..end_time.to_i).pluck(:uid)
      answers = Answer.where(created_at: start_time..end_time).pluck(:uid)
      questions = Node.questions.where(status: 1, created: start_time.to_i..end_time.to_i).pluck(:uid)
      comments = Comment.where(timestamp: start_time.to_i..end_time.to_i).pluck(:uid)
      revisions = Revision.where(status: 1, timestamp: start_time.to_i..end_time.to_i).pluck(:uid)
      contributors = (notes + answers + questions + comments + revisions).compact.uniq.size
      contributors
    end

    def create_with_omniauth(auth)
      random_chars = [*'A'..'Z', *'a'..'z', *0..9].sample(2).join

      email_prefix = auth["info"]["email"].tr('.', '_').split('@')[0]
      email_prefix = auth["info"]["email"].tr('.', '_').split('@')[0] + random_chars until User.where(username: email_prefix).empty?

      provider = { "facebook" => 1, "github" => 2, "google_oauth2" => 3, "twitter" => 4 }

      create! do |user|
        generated_password = SecureRandom.urlsafe_base64

        user.username = email_prefix
        user.email = auth["info"]["email"]
        user.password = generated_password
        user.status = Status::NORMAL
        user.password_confirmation = generated_password
        user.password_checker = provider[auth["provider"]]
        user.save!
      end
    end

    def count_all_time_contributor
      notes = Node.where(type: 'note', status: 1).pluck(:uid)
      answers = Answer.pluck(:uid)
      questions = Node.questions.where(status: 1).pluck(:uid)
      comments = Comment.pluck(:uid)
      revisions = Revision.where(status: 1).pluck(:uid)

      (notes + answers + questions + comments + revisions).compact.uniq.size
    end

    def watching_location(nwlat, selat, nwlng, selng)
      raise("Must be a float") unless (nwlat.is_a? Float) && (nwlng.is_a? Float) && (selat.is_a? Float) && (selng.is_a? Float)

      tids = Tag.where("SUBSTRING_INDEX(term_data.name,':',1) = ? \
        AND SUBSTRING_INDEX(SUBSTRING_INDEX(term_data.name, ':', 2),':',-1)+0 <= ? \
        AND SUBSTRING_INDEX(SUBSTRING_INDEX(term_data.name, ':', 3),':',-1)+0 <= ? \
        AND SUBSTRING_INDEX(SUBSTRING_INDEX(term_data.name, ':', 4),':',-1)+0 <= ? \
        AND SUBSTRING_INDEX(term_data.name, ':', -1) <= ?", 'subscribed', nwlat, nwlng, selat, selng).collect(&:tid).uniq || []
      uids = TagSelection.where('tag_selections.tid IN (?)', tids).collect(&:user_id).uniq || []

      User.where("id IN (?)", uids).order(:id)
    end
  end

  def recent_locations(limit = 5)
    recent_nodes = self.nodes.includes(:tag)
      .references(:term_data)
      .where('term_data.name LIKE ?', 'lat:%')
      .joins("INNER JOIN term_data AS lon_tag ON lon_tag.name LIKE 'lat:%'")
      .order(created: :desc)
      .limit(5)
  end

  def latest_location
    recent_locations.last
  end

  private

  def decrease_likes_banned
    node_selections.each do |selection|
      selection.node.cached_likes -= 1
      selection.node.save!
    end
  end

  def increase_likes_unbanned
    node_selections.each do |selection|
      selection.node.cached_likes += 1
      selection.node.save!
    end
  end

  def map_openid_registration(registration)
    self.email = registration['email'] if email.blank?
    self.username = registration['nickname'] if username.blank?
  end
end
