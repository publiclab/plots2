class DrupalUser < ActiveRecord::Base
  attr_accessible :title, :body, :name, :pass, :mail, :mode, :sort, :threshold, :theme, :signature, :signature_format, :created, :access, :login, :status, :timezone, :language, :picture, :init, :data, :timezone_id, :timezone_name

  ## User status can be:
  #  0: banned
  #  1: normal
  #  5: moderated

  self.table_name = 'users'
  self.primary_key = 'uid'

  has_many :node, foreign_key: 'uid'
  has_many :drupal_profile_values, foreign_key: 'uid'
  has_many :node_selections, foreign_key: :user_id
  has_many :answers, foreign_key: :uid
  has_many :answer_selections, foreign_key: :user_id
  has_many :comments, foreign_key: 'uid'


  include SolrToggle
  searchable if: :internalShouldIndexSolr do
    string :name
    string :mail
    string :status
  end

  def internalShouldIndexSolr
    shouldIndexSolr && status == 1
  end

  def user
    User.where(username: name).first
  end

  def bio
    user.bio
  end
  
  def username
    name
  end

  def using_new_site?
    !User.find_by(username: name).nil?
  end

  # Rails-style adaptors:

  def created_at
    Time.at(created)
  end

  # End rails-style adaptors

  def role
    user.role if user
  end

  def moderate
    self.status = 5
    save
    # user is logged out next time they access current_user in a controller; see application controller
    self
  end

  def unmoderate
    self.status = 1
    save
    self
  end

  def ban
    self.status = 0
    decrease_likes_banned
    save
    # user is logged out next time they access current_user in a controller; see application controller
    self
  end

  def unban
    self.status = 1
    increase_likes_unbanned
    save
    self
  end

  def email
    mail
  end

  def first_time_poster
    user.first_time_poster
  end

  def likes
    NodeSelection.where(user_id: uid, liking: true)
  end

  def like_count
    NodeSelection.where(user_id: uid, liking: true).count
  end

  def liked_notes
    Node.includes(:node_selections)
        .references(:node_selections)
        .where("type = 'note' AND node_selections.liking = ? AND node_selections.user_id = ? AND node.status = 1", true, uid)
        .order('node_selections.nid DESC')
  end

  def liked_pages
    NodeSelection.where("status = 1 AND user_id = ? AND liking = ? AND (node.type = 'page' OR node.type = 'tool' OR node.type = 'place')", uid, true)
                 .includes(:node)
                 .references(:node)
                 .collect(&:node)
                 .reverse
  end

  # last node
  def last
    Node.limit(1)
        .where(uid: uid)
        .order('changed DESC')
        .first
  end

  def profile_values
    drupal_profile_values
  end

  def notes
    user.notes
  end

  def note_count
    Node.where(status: 1, uid: uid, type: 'note').count
  end

  def node_count
    Node.where(status: 1, uid: uid).count + Revision.where(uid: uid).count
  end

  # accepts array of tag names (strings)
  def notes_for_tags(tagnames)
    all_nodes = Node.order('nid DESC').where(type: 'note', status: 1, uid: uid)
    node_ids = []
    all_nodes.each do |node|
      node.tags.each do |tag|
        tagnames.each do |tagname|
          node_ids << node.nid if tag.name == tagname
        end
      end
    end
    Node.find(node_ids.uniq, order: 'nid DESC')
  end

  def user_tags
    self.user.user_tags
  end

  def tags(limit = 10)
    self.user.tags(limit)
  end

  def tagnames(limit = 20, defaults = true)
    self.user.tagnames(limit, defaults)
  end

  def tag_counts
    tags = {}
    Node.order('nid DESC').where(type: 'note', status: 1, uid: uid).limit(20).each do |node|
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
    u = User.new(username: name,
                 id: uid,
                 email: mail,
                 openid_identifier: '//old.publiclab.org/user/' + uid.to_s + '/identity')
    u.persistence_token = rand(100_000_000)
    if u.save(validate: false) # <= because validations checks for conflict with existing drupal_user.name
      key = u.generate_reset_key
      PasswordResetMailer.reset_notify(u, key)
      return true
    else
      return false
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
end
