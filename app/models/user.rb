class UniqueUsernameValidator < ActiveModel::Validator
  def validate(record)
    if User.find_by(username: record.username) && record.openid_identifier.nil?
      record.errors[:base] << 'That username is already taken. If this is your username, you can simply log in to this site.'
    end
  end
end

class User < ActiveRecord::Base
  extend Utils
  include Statistics
  self.table_name = 'rusers'
  alias_attribute :name, :username

  NORMAL = 1 # Usage: User::NORMAL
  BANNED = 0 # Usage: User::BANNED
  MODERATED = 5 # Usage: User::MODERATED

  acts_as_authentic do |c|
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    c.validates_format_of_email_field_options = { with: VALID_EMAIL_REGEX }
    c.crypto_provider = Authlogic::CryptoProviders::Sha512
  end

  has_attached_file :photo, styles: { thumb: '200x200#', medium: '500x500#', large: '800x800#' },
                            url: '/system/profile/photos/:id/:style/:basename.:extension'
  #:path => ":rails_root/public/system/images/photos/:id/:style/:basename.:extension"
  do_not_validate_attachment_file_type :photo_file_name
  # validates_attachment_content_type :photo_file_name, :content_type => %w(image/jpeg image/jpg image/png)

  has_many :images, foreign_key: :uid
  has_many :node, foreign_key: 'uid'
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
  validates_format_of :username, with: /\A[A-Za-z\d_\-]+\z/

  before_save :set_token

  scope :past_week, -> { where("created_at > ?", Time.now - 7.days) }
  scope :past_month, -> { where("created_at > ?", Time.now - 1.months) }

  def self.search(query)
    User.where('MATCH(bio, username) AGAINST(? IN BOOLEAN MODE)', query + '*')
  end

  def self.search_by_username(query)
    User.where('MATCH(username) AGAINST(? IN BOOLEAN MODE)', query + '*')
  end

  def is_new_contributor
    Node.where(uid: id).length === 1 && Node.where(uid: id).first.created_at > Date.today - 1.month
  end

  def new_contributor
    return "<a href='/tag/first-time-poster' class='label label-success'><i>new contributor</i></a>".html_safe if is_new_contributor
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
    # invent a key and save it
    key = ''
    20.times do
      key += [*'a'..'z'].sample
    end
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
  def has_role(r)
    role == r
  end

  def admin?
    role == 'admin'
  end

  def moderator?
    role == 'moderator'
  end

  def can_moderate?
    # use instead of "user.role == 'admin' || user.role == 'moderator'"
    admin? || moderator?
  end

  def is_coauthor(node)
    id == node.author.id || node.has_tag("with:#{username}")
  end

  def tags(limit = 10)
    Tag.where('name in (?)', tagnames).limit(limit)
  end

  def tagnames(limit = 20, defaults = true)
    tagnames = []
    Node.order('nid DESC').where(type: 'note', status: 1, uid: id).limit(limit).each do |node|
      tagnames += node.tags.collect(&:name)
    end
    tagnames += ['balloon-mapping', 'spectrometer', 'near-infrared-camera', 'thermal-photography', 'newsletter'] if tagnames.empty? && defaults
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
    notes.where(status: 1).count == 0
  end
  
  def first_time_commenter
    Comment.where(status: 1, uid: uid).count == 0
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

  def profile_image
    if photo_file_name
      puts photo_path(:thumb)
      photo_path(:thumb)
    else
      "https://www.gravatar.com/avatar/#{OpenSSL::Digest::MD5.hexdigest(email)}"
    end
  end

  def questions
    Node.questions.where(status: 1, uid: id)
  end

  def content_followed_in_period(start_time, end_time)
    tagnames = TagSelection.where(following: true, user_id: uid)
    node_ids = []
    tagnames.each do |tagname|
      node_ids += NodeTag.where(tid: tagname.tid).collect(&:nid)
    end

    Node.where(nid: node_ids)
      .includes(:revision, :tag)
      .references(:node_revision)
      .where('node.status = 1')
      .where("(created >= #{start_time.to_i} AND created <= #{end_time.to_i}) OR (timestamp >= #{start_time.to_i}  AND timestamp <= #{end_time.to_i})")
      .order('node_revisions.timestamp DESC')
      .distinct
  end

  def social_link(site)
    if has_power_tag(site)
      user_name = get_last_value_of_power_tag(site)
      link = "https://#{site}.com/#{user_name}"
      return link
    end
    nil
  end

  def moderate
    self.status = 5
    self.save({})
    # user is logged out next time they access current_user in a controller; see application controller
    self
  end

  def unmoderate
    self.status = 1
    self.save({})
    self
  end

  def ban
    decrease_likes_banned
    self.status = 0
    self.save({})
    # user is logged out next time they access current_user in a controller; see application controller
    self
  end

  def unban
    increase_likes_unbanned
    self.status = 1
    self.save({})
    self
  end

  def banned?
    status.zero?
  end

  def note_count
    Node.where(status: 1, uid: uid, type: 'note').count
  end

  def node_count
    Node.where(status: 1, uid: uid).count + Revision.where(uid: uid).count
  end

  def liked_notes
    Node.includes(:node_selections)
      .references(:node_selections)
      .where("type = 'note' AND node_selections.liking = ? AND node_selections.user_id = ? AND node.status = 1", true, id)
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
    top_picks = content_followed_in_period(Time.now - 1.week, Time.now)
    if top_picks.count > 0
      SubscriptionMailer.send_digest(id, top_picks).deliver_now
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
    user_id_and_time = { :id => id, :timestamp => Time.now }
    User.encrypt(user_id_and_time)
  end

  def self.validate_token(token)
    begin
      decrypted_data = User.decrypt(token)      
    rescue ActiveSupport::MessageVerifier::InvalidSignature => e
      puts e.message
      return 0
    end
    if (Time.now - decrypted_data[:timestamp]) / 1.hour > 24.0
      return 0
    else
      return decrypted_data[:id]   
    end
  end

  private

  def decrease_likes_banned
    node_selections.each do |selection|
      selection.node.cached_likes = selection.node.cached_likes - 1
      selection.node.save!
    end
  end

  def increase_likes_unbanned
    node_selections.each do |selection|
      selection.node.cached_likes = selection.node.cached_likes + 1
      selection.node.save!
    end
  end

  def map_openid_registration(registration)
    self.email = registration['email'] if email.blank?
    self.username = registration['nickname'] if username.blank?
  end

  def self.find_by_username_case_insensitive(username)
    User.where('lower(username) = ?', username.downcase).first
  end

  # all uses who've posted a node, comment, or answer in the given period
  def self.contributor_count_for(start_time, end_time)
    notes = Node.where(type: 'note', status: 1, created: start_time.to_i..end_time.to_i).pluck(:uid)
    answers = Answer.where(created_at: start_time..end_time).pluck(:uid)
    questions = Node.questions.where(status: 1, created: start_time.to_i..end_time.to_i).pluck(:uid)
    comments = Comment.where(timestamp: start_time.to_i..end_time.to_i).pluck(:uid)
    revisions = Revision.where(status: 1, timestamp: start_time.to_i..end_time.to_i).pluck(:uid)
    contributors = (notes + answers + questions + comments + revisions).compact.uniq.length
    contributors
  end

  def self.create_with_omniauth(auth)
    # email prefix is part of email before @ with periods replaced with underscores
    # generate a 2 digit alphanumeric number and append it at the end of email-prefix
    charset = Array('A'..'Z') + Array('a'..'z') + Array(0..9)
    email_prefix = auth["info"]["email"].tr('.', '_').split('@')[0]
    email_prefix = auth["info"]["email"].tr('.', '_').split('@')[0] + Array.new(2) { charset.sample }.join until User.where(username: email_prefix).empty?
    hash = { "facebook" => 1, "github" => 2, "google_oauth2" => 3, "twitter" => 4 }
    create! do |user|
      s = SecureRandom.urlsafe_base64
      user.username = email_prefix
      user.email = auth["info"]["email"]
      user.password = s
      user.password_confirmation = s
      user.password_checker = hash[auth["provider"]]
      user.save!
    end
  end
  
  def self.count_all_time_contributor
    notes = Node.where(type: 'note', status: 1).pluck(:uid)
    answers = Answer.pluck(:uid)
    questions = Node.questions.where(status: 1).pluck(:uid)
    comments = Comment.pluck(:uid)
    revisions = Revision.where(status: 1).pluck(:uid)
    contributors = (notes + answers + questions + comments + revisions).compact.uniq.length
  end
end
