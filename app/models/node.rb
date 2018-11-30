class UniqueUrlValidator < ActiveModel::Validator
  def validate(record)
    if record.title == '' || record.title.nil?
      # record.errors[:base] << "You must provide a title."
      # otherwise the below title uniqueness check fails, as title presence validation doesn't run until after
    elsif record.type == 'page'
      array = %w(create edit update delete new)
      array.each do |x|
        if record.title == x
          record.errors[:base] << "You may not use the title '" + x + "'"
        end
      end
    else
      if !Node.where(path: record.generate_path).first.nil? && record.type == 'note'
        record.errors[:base] << 'You have already used this title.'
      end
    end
  end
end

class Node < ActiveRecord::Base
  include NodeShared # common methods for node-like models

  self.table_name = 'node'
  self.primary_key = 'nid'

  def self.search(query:, order: :default, type: :natural, limit: 25)
    order_param = if order == :default
                    { changed: :desc }
                  elsif order == :likes
                    { cached_likes: :desc }
                  elsif order == :views
                    { views: :desc }
                  end

    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      if order == :natural
        query = connection.quote(query.to_s)
        if type == :boolean
          # Query is done as a boolean full-text search. More info here: https://dev.mysql.com/doc/refman/5.5/en/fulltext-boolean.html
          nids = Revision.select("node_revisions.nid, node_revisions.body, node_revisions.title, MATCH(node_revisions.body, node_revisions.title) AGAINST(#{query} IN BOOLEAN MODE) AS score")
            .where("MATCH(node_revisions.body, node_revisions.title) AGAINST(#{query} IN BOOLEAN MODE)")
            .limit(limit)
            .distinct
            .collect(&:nid)
        else
          nids = Revision.select("node_revisions.nid, node_revisions.body, node_revisions.title, MATCH(node_revisions.body, node_revisions.title) AGAINST(#{query} IN NATURAL LANGUAGE MODE) AS score")
            .where("MATCH(node_revisions.body, node_revisions.title) AGAINST(#{query} IN NATURAL LANGUAGE MODE)")
            .limit(limit)
            .distinct
            .collect(&:nid)
        end
        where(nid: nids, status: 1)
      else
        nids = Revision.where('MATCH(node_revisions.body, node_revisions.title) AGAINST(?)', query).collect(&:nid)
        tnids = Tag.find_nodes_by_type(query, type = %w(note page)).collect(&:nid) # include results by tag
        where(nid: nids + tnids, status: 1)
          .order(order_param)
          .limit(limit)
          .distinct
      end
    else
      nodes = Node.limit(limit)
        .where('title LIKE ?', '%' + query + '%')
        .where(status: 1)
        .order(order_param)
    end
  end

  def updated_month
    updated_at.strftime('%B %Y')
  end

  has_many :revision, foreign_key: 'nid' # , dependent: :destroy # re-enable in Rails 5
  # wasn't working to tie it to .vid, manually defining below
  #  has_one :drupal_main_image, :foreign_key => 'vid', :dependent => :destroy
  #  has_many :drupal_content_field_image_gallery, :foreign_key => 'nid'
  has_many :drupal_upload, foreign_key: 'nid' # , dependent: :destroy # re-enable in Rails 5
  has_many :drupal_files, through: :drupal_upload
  has_many :node_tag, foreign_key: 'nid' # , dependent: :destroy # re-enable in Rails 5
  has_many :tag, through: :node_tag
  # these override the above... have to do it manually:
  # has_many :tag, :through => :drupal_node_tag
  has_many :comments, foreign_key: 'nid', dependent: :destroy # re-enable in Rails 5
  has_many :drupal_content_type_map, foreign_key: 'nid' # , dependent: :destroy # re-enable in Rails 5
  has_many :drupal_content_field_mappers, foreign_key: 'nid' # , dependent: :destroy # re-enable in Rails 5
  has_many :drupal_content_field_map_editor, foreign_key: 'nid' # , dependent: :destroy # re-enable in Rails 5
  has_many :images, foreign_key: :nid
  has_many :node_selections, foreign_key: :nid, dependent: :destroy
  has_many :answers, foreign_key: :nid, dependent: :destroy

  belongs_to :drupal_user, foreign_key: 'uid'

  validates :title, presence: :true
  validates_with UniqueUrlValidator, on: :create

  # making drupal and rails database conventions play nice;
  # 'changed' is a reserved word in rails
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name == 'changed'
      return true if method_name == 'changed?'
      super
    end
  end

  # making drupal and rails database conventions play nice;
  # 'type' is a reserved word in rails
  def self.inheritance_column
    'rails_type'
  end

  def slug_from_path
    path.split('/').last
  end

  before_save :set_changed_and_created
  after_create :setup
  before_validation :set_path_and_slug, on: :create

  # can switch to a "question-style" path if specified
  def path(type = :default)
    if type == :question
      self[:path].gsub('/notes/', '/questions/')
    else
      # default path
      self[:path]
    end
  end

  # should only be run at actual creation time --
  # or, we should refactor to us node.created instead of Time.now
  def generate_path
    if type == 'note'
      username = DrupalUser.find_by(uid: uid).name
      "/notes/#{username}/#{Time.now.strftime('%m-%d-%Y')}/#{title.parameterize}"
    elsif type == 'page'
      '/wiki/' + title.parameterize
    elsif type == 'map'
      "/map/#{title.parameterize}/#{Time.now.strftime('%m-%d-%Y')}"
    elsif type == 'feature'
      "/feature/#{title.parameterize}"
    end
  end

  private

  def set_path_and_slug
    self.path = generate_path if path.blank? && !title.blank?
    self.slug = path.split('/').last unless path.blank?
  end

  def set_changed_and_created
    self['changed'] = DateTime.now.to_i
  end

  # determines URL ("slug"), and sets up a created timestamp
  def setup
    self['created'] = DateTime.now.to_i
    save
  end

  public

  is_impressionable counter_cache: true, column_name: :views

  def totalviews
    # this doesn't filter out duplicate ip addresses as the line below does:
    # self.views + self.legacy_views
    impressionist_count(filter: :ip_address) + legacy_views
  end

  def self.weekly_tallies(type = 'note', span = 52, time = Time.now)
    weeks = {}
    (0..span).each do |week|
      weeks[span - week] = Node.select(:created)
                               .where(type:    type,
                                      status:  1,
                                      created: time.to_i - week.weeks.to_i..time.to_i - (week - 1).weeks.to_i)
                               .count
    end
    weeks
  end

  def self.contribution_graph_making(type = 'note', span = 52, time = Time.now)
    weeks = {}
    week = span
    count = 0
    while week >= 1
      # initialising month variable with the month of the starting day
      # of the week
      month = (time - (week * 7 - 1).days).strftime('%m')

      # Now fetching the weekly data of notes or wikis
      month = month.to_i
      current_week = Node.select(:created)
                     .where(type: type,
                            status: 1,
                            created: time.to_i - week.weeks.to_i..time.to_i - (week - 1).weeks.to_i)
                      .count
      weeks[count] = [month, current_week]
      count += 1
      week -= 1
    end
    weeks
  end

  def notify
    if status == 4
      AdminMailer.notify_node_moderators(self).deliver_now
    else
      SubscriptionMailer.notify_node_creation(self).deliver_now
    end
  end

  def publish
    self.status = 1
    save
    self
  end

  def spam
    self.status = 0
    save
    self
  end

  def files
    drupal_files
  end

  def answered
    answers&.length&.positive?
  end

  def has_accepted_answers
    answers.where(accepted: true).count.positive?
  end

  # users who like this node
  def likers
    node_selections
      .joins(:drupal_user)
      .references(:users)
      .where(liking: true)
      .where('users.status = ?', 1)
      .collect(&:user)
  end

  def latest
    revisions
      .where(status: 1)
      .order(timestamp: :desc)
      .first
  end

  def revisions
    revision
      .order(timestamp: :desc)
  end

  def revision_count
    revision
      .count
  end

  def comment_count
    comments
      .count
  end

  def author
    DrupalUser.find_by(uid: uid)
  end

  def coauthors
    User.where(username: power_tags('with')) if has_power_tag('with')
  end

  # for wikis:
  def authors
    revisions.collect(&:author).uniq
  end

  # tag- and node-based followers
  def subscribers(conditions = false)
    users = TagSelection.where(tid: tags.collect(&:tid))
                        .collect(&:user)
    users += NodeSelection.where(nid: nid)
                          .collect(&:user)

    users = users.where(conditions) if conditions
    users.uniq
  end

  # view adaptors for typical rails db conventions so we can migrate someday
  def id
    nid
  end

  def created_at
    Time.at(created)
  end

  def updated_at
    Time.at(self['changed'])
  end

  def body
    latest&.body
  end

  # was unable to set up this relationship properly with ActiveRecord associations
  def drupal_main_image
    DrupalMainImage.order('vid')
                   .where('nid = ? AND field_main_image_fid IS NOT NULL', nid)
                   .last
  end

  # provide either a Drupally main_image or a Railsy one
  def main_image(node_type = :all)
    if !images.empty? && node_type != :drupal
      if main_image_id.blank?
        images.order('vid').last
      else
        images.where(id: main_image_id).first
      end
    elsif drupal_main_image && node_type != :rails
      drupal_main_image.drupal_file
    end
  end

  # scan for first image in the body and use this instead
  # (in future, maybe just do this for all images?)
  def scraped_image
    latest.render_body.scan(/<img(.*?)\/>/)&.first if latest
  end

  # was unable to set up this relationship properly with ActiveRecord associations
  def drupal_content_field_image_gallery
    DrupalContentFieldImageGallery.where(nid: nid)
                                  .order('field_image_gallery_fid')
  end

  def gallery
    if !drupal_content_field_image_gallery.empty? && drupal_content_field_image_gallery.first.field_image_gallery_fid
      drupal_content_field_image_gallery
    else
      []
    end
  end

  # ============================================
  # Tag-related methods

  def has_mailing_list?
    has_power_tag('list')
  end

  # Nodes this node is responding to with a `response:<nid>` power tag;
  # The key word "response" can be customized, i.e. `replication:<nid>` for other uses.
  def responded_to(key = 'response')
    Node.where(nid: power_tags(key)) || []
  end

  # Nodes that respond to this node with a `response:<nid>` power tag;
  # The key word "response" can be customized, i.e. `replication:<nid>` for other uses.
  def responses(key = 'response')
    Tag.find_nodes_by_type([key + ':' + id.to_s])
  end

  # Nodes that respond to this node with a `response:<nid>` power tag;
  # The key word "response" can be customized, i.e. `replication:<nid>` for other uses.
  def response_count(key = 'response')
    Node.where(status: 1, type: 'note')
        .includes(:revision, :tag)
        .references(:term_data)
        .where('term_data.name = ?', "#{key}:#{id}")
        .count
  end

  # power tags have "key:value" format, and should be searched with a "key:*" wildcard
  def has_power_tag(key)
    tids = Tag.includes(:node_tag)
              .references(:community_tags)
              .where('community_tags.nid = ? AND name LIKE ?', id, key + ':%')
              .collect(&:tid)
    !NodeTag.where('nid = ? AND tid IN (?)', id, tids).empty?
  end

  # returns the value for the most recent power tag of form key:value
  def power_tag(tag)
    tids = Tag.includes(:node_tag)
              .references(:community_tags)
              .where('community_tags.nid = ? AND name LIKE ?', id, tag + ':%')
              .collect(&:tid)
    node_tag = NodeTag.where('nid = ? AND tid IN (?)', id, tids)
                                     .order('nid DESC')
    if node_tag&.first
      node_tag.first.tag.name.gsub(tag + ':', '')
    else
      ''
    end
  end

  # returns all tagnames for a given power tag
  def power_tags(tag)
    tids = Tag.includes(:node_tag)
              .references(:community_tags)
              .where('community_tags.nid = ? AND name LIKE ?', id, tag + ':%')
              .collect(&:tid)
    node_tags = NodeTag.where('nid = ? AND tid IN (?)', id, tids)
    tags = []
    node_tags.each do |nt|
      tags << nt.name.gsub(tag + ':', '')
    end
    tags
  end

  # returns all power tag results as whole community_tag objects
  def power_tag_objects(tag)
    tids = Tag.includes(:node_tag)
              .references(:community_tags)
              .where('community_tags.nid = ? AND name LIKE ?', id, tag + ':%')
              .collect(&:tid)
    NodeTag.where('nid = ? AND tid IN (?)', id, tids)
  end

  # return whole community_tag objects but no powertags or "event"
  def normal_tags
    tids = Tag.includes(:node_tag)
              .references(:community_tags)
              .where('community_tags.nid = ? AND name LIKE ?', id, '%:%')
              .collect(&:tid)
    NodeTag.where('nid = ? AND tid NOT IN (?)', id, tids)
  end

  # accests a tagname /or/ tagname ending in wildcard such as "tagnam*"
  # also searches for other tags whose parent field matches given tagname,
  # but not tags matching given tag's parent field
  def has_tag(tagname)
    tags = get_matching_tags_without_aliasing(tagname)
    # search for tags with parent matching this
    tags += Tag.includes(:node_tag)
               .references(:community_tags)
               .where('community_tags.nid = ? AND parent LIKE ?', id, tagname)
    # search for parent tag of this, if exists
    # tag = Tag.where(name: tagname).try(:first)
    # if tag && tag.parent
    #  tags += Tag.includes(:node_tag)
    #             .references(:community_tags)
    #             .where("community_tags.nid = ? AND name LIKE ?", self.id, tag.parent)
    # end
    tids = tags.collect(&:tid).uniq
    !NodeTag.where('nid IN (?) AND tid IN (?)', id, tids).empty?
  end

  # can return multiple Tag records -- we don't yet hard-enforce uniqueness, but should soon
  # then, this would just be replaced by Tag.where(name: tagname).first
  def get_matching_tags_without_aliasing(tagname)
    tags = Tag.includes(:node_tag)
              .references(:community_tags)
              .where('community_tags.nid = ? AND name LIKE ?', id, tagname)
    # search for tags which end in wildcards
    if tagname[-1] == '*'
      tags += Tag.includes(:node_tag)
                 .references(:community_tags)
                 .where('community_tags.nid = ? AND (name LIKE ? OR name LIKE ?)', id, tagname, tagname.tr('*', '%'))
    end
    tags
  end

  def has_tag_without_aliasing(tagname)
    tags = get_matching_tags_without_aliasing(tagname)
    tids = tags.collect(&:tid).uniq
    !NodeTag.where('nid IN (?) AND tid IN (?)', id, tids).empty?
  end

  # has it been tagged with "list:foo" where "foo" is the name of a Google Group?
  def mailing_list
    Rails.cache.fetch('feed-' + id.to_s + '-' + (updated_at.to_i / 300).to_i.to_s) do
      RSS::Parser.parse(open('https://groups.google.com/group/' + power_tag('list') + '/feed/rss_v2_0_topics.xml').read, false).items
    end
  rescue StandardError
    return []
  end

  # End of tag-related methods

  # used in typeahead autocomplete search results
  def icon
    icon = 'file' if type == 'note'
    icon = 'book' if type == 'page'
    icon = 'map-marker' if type == 'map'
    icon = 'flag' if has_tag('chapter')
    icon = 'wrench' if type == 'tool'
    icon = 'question-circle' if has_power_tag('question')
    icon
  end

  def tags
    tag
  end

  def node_tags
    node_tag
  end

  def tagnames
    tags.collect(&:name)
  end

  # Here we re-query to fetch /all/ tagnames; this is used in
  # /views/notes/_notes.html.erb in a way that would otherwise only
  # return a single tag due to a join, yet select() keeps this efficient
  def tagnames_as_classes
    Node.select([:nid])
        .find(id)
        .tagnames
        .map { |t| 'tag-' + t.tr(':', '-') }
        .join(' ')
  end

  def edit_path
    path = if type == 'page' || type == 'tool' || type == 'place'
             '/wiki/edit/' + self.path.split('/').last
           else
             '/notes/edit/' + id.to_s
    end
    path
  end

  def self.find_by_path(title)
    Node.where(path: ["/#{title}"]).first
  end

  def map
    # This fires off a query that orders by vid DESC
    # and is quicker than doing .order(vid: :DESC) for some reason.
    drupal_content_type_map.last
  end

  def blurred?
    has_power_tag('location') && power_tag('location') == "blurred"
  end

  def lat
    if has_power_tag('lat')
      power_tag('lat').to_f
    else
      false
    end
  end

  def lon
    if has_power_tag('lon')
      power_tag('lon').to_f
    else
      false
    end
  end

  # these should eventually displace the above means of finding locations
  # ...they may already be redundant after tagged_map_coord migration
  def tagged_lat
    power_tags('lat')[0]
  end

  def tagged_lon
    power_tags('lon')[0]
  end

  def next_by_author
    Node.where('uid = ? and nid > ? and type = "note"', author.uid, nid)
        .order('nid')
        .first
  end

  def prev_by_author
    Node.where('uid = ? and nid < ? and type = "note"', author.uid, nid)
        .order('nid desc')
        .first
  end

  # ============================================
  # Automated constructors for associated models

  def add_comment(params = {})
    thread = if !comments.empty? && !comments.last.nil?
               comments.last.next_thread
             else
               '01/'
    end
    if params[:comment_via].nil?
      comment_via_status = 0
    else
      comment_via_status = params[:comment_via].to_i
    end
    c = Comment.new(pid: 0,
                    nid: nid,
                    uid: params[:uid],
                    subject: '',
                    hostname: '',
                    comment: params[:body],
                    status: 1,
                    format: 1,
                    thread: thread,
                    timestamp: DateTime.now.to_i,
                    comment_via: comment_via_status,
                    message_id: params[:message_id])
    c.save
    c
  end

  def new_revision(params)
    title = params[:title] || self.title
    Revision.new(nid: id,
                 uid: params[:uid],
                 title: title,
                 body: params[:body])
  end

  # handle creating a new note with attached revision and main image
  # this is kind of egregiously bad... must revise after
  # researching simultaneous creation of associated records
  def self.new_note(params)
    saved = false
    author = DrupalUser.find(params[:uid])
    node = Node.new(uid:     author.uid,
                    title:   params[:title],
                    comment: 2,
                    type:    'note')
    node.status = 4 if author.first_time_poster
    node.draft if params[:draft] == "true"

    if node.valid? # is this not triggering title uniqueness validation?
      saved = true
      revision = false
      ActiveRecord::Base.transaction do
        node.save!
        revision = node.new_revision(uid:   author.uid,
                                     title: params[:title],
                                     body:  params[:body])
        if revision.valid?
          revision.save!
          node.vid = revision.vid
          # save main image
          if params[:main_image] && (params[:main_image] != '')
            img = Image.find params[:main_image]
            img.nid = node.id
            img.save
          end
          node.save!
          if node.status != 3
            node.notify
          end
        else
          saved = false
          node.destroy
        end
      end
    end
    [saved, node, revision]
  end

  def self.new_wiki(params)
    saved = false
    node = Node.new(uid: params[:uid],
                    title: params[:title],
                    type: 'page')
    if node.valid?
      revision = false
      saved = true
      ActiveRecord::Base.transaction do
        node.save!
        revision = node.new_revision(nid: node.id,
                                     uid: params[:uid],
                                     title: params[:title],
                                     body: params[:body])
        if revision.valid?
          revision.save!
          node.vid = revision.vid
          node.save!
          # node.notify # we don't yet notify of wiki page creations
        else
          saved = false
          node.destroy # clean up
        end
      end
    end
    [saved, node, revision]
  end

  # same as new_note or new_wiki but with arbitrary type -- use for maps, DRY out new_note and new_wiki
  def self.new_node(params)
    saved = false
    node = Node.new(uid: params[:uid],
                    title: params[:title],
                    type: params[:type])
    if node.valid?
      revision = false
      saved = true
      ActiveRecord::Base.transaction do
        node.save!
        revision = node.new_revision(nid: node.id,
                                     uid: params[:uid],
                                     title: params[:title],
                                     body: params[:body])
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
    [saved, node, revision]
  end

  def barnstar
    power_tag_objects('barnstar').first
  end

  def barnstars
    power_tag_objects('barnstar')
  end

  def add_barnstar(tagname, giver)
    add_tag(tagname, giver.drupal_user)
    CommentMailer.notify_barnstar(giver, self).deliver_now
  end

  def add_tag(tagname, user)
    tagname = tagname.downcase
    unless has_tag_without_aliasing(tagname)
      saved = false
      tag = Tag.find_by(name: tagname) || Tag.new(vid:         3, # vocabulary id; 1
                                                  name:        tagname,
                                                  description: '',
                                                  weight:      0)

      ActiveRecord::Base.transaction do
        if tag.valid?
          if tag.name.split(':')[0] == 'date'
            begin
              DateTime.strptime(tag.name.split(':')[1], '%m-%d-%Y').to_date.to_s(:long)
            rescue StandardError
              return [false, tag.destroy]
            end
          end
          tag.save!
          node_tag = NodeTag.new(tid: tag.id,
                                 uid: user.uid,
                                 date: DateTime.now.to_i,
                                 nid: id)
          if node_tag.save
            saved = true
            # send email notification if there are subscribers, status is OK, and less than 1 month old
            unless tag.subscriptions.empty? || status == 3 || status == 4 || created < (DateTime.now - 1.month).to_i
              SubscriptionMailer.notify_tag_added(self, tag, user).deliver_now
            end
          else
            saved = false
            tag.destroy
          end
        end
      end
      return [saved, tag]
    end
  end

  def mentioned_users
    usernames = body.scan(Callouts.const_get(:FINDER))
    User.where(username: usernames.map { |m| m[1] }).uniq
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

  def body_preview(length = 100)
    try(:latest).body_preview(length)
  end

  # so we can quickly fetch questions corresponding to this node
  # with node.questions
  def questions
    # override with a tag like `questions:h2s`
    if has_power_tag('questions')
      tagname = power_tag('questions')
    else
      tagname = slug_from_path
    end
    Node.where(status: 1, type: 'note')
        .includes(:revision, :tag)
        .references(:term_data)
        .where('term_data.name LIKE ?', "question:#{tagname}")
  end

  # all questions
  def self.questions
    questions = Node.where(type: 'note')
                    .joins(:tag)
                    .where('term_data.name LIKE ?', 'question:%')
                    .group('node.nid')
  end

  # so we can quickly fetch activities corresponding to this node
  # with node.activities
  def activities
    # override with a tag like `activities:h2s`
    if has_power_tag('activities')
      tagname = power_tag('activities')
    else
      tagname = slug_from_path
    end
    Node.activities(tagname)
  end

  # so we can call Node.activities('balloon-mapping')
  def self.activities(tagname)
    Node.where(status: 1, type: 'note')
        .includes(:revision, :tag)
        .references(:term_data)
        .where('term_data.name LIKE ?', "activity:#{tagname}")
  end

  # so we can quickly fetch upgrades corresponding to this node
  # with node.upgrades
  def upgrades
    # override with a tag like `upgrades:h2s`
    if has_power_tag('upgrades')
      tagname = node.power_tag('upgrades')
    else
      tagname = slug_from_path
    end
    Node.upgrades(tagname)
  end

  # so we can call Node.upgrades('balloon-mapping')
  def self.upgrades(tagname)
    Node.where(status: 1, type: 'note')
        .includes(:revision, :tag)
        .references(:term_data)
        .where('term_data.name LIKE ?', "upgrade:#{tagname}")
  end

  def can_tag(tagname, user, errors = false)
    if tagname[0..4] == 'with:'
      if User.find_by_username_case_insensitive(tagname.split(':')[1]).nil?
        errors ? I18n.t('node.cannot_find_username') : false
      elsif author.uid != user.uid
        errors ? I18n.t('node.only_author_use_powertag') : false
      elsif tagname.split(':')[1] == user.username
        errors ? I18n.t('node.cannot_add_yourself_coauthor') : false
      else
        true
      end
    elsif tagname == 'format:raw' && user.role != 'admin'
      errors ? "Only admins may create raw pages." : false
    elsif tagname[0..4] == 'rsvp:' && user.username != tagname.split(':')[1]
      errors ? I18n.t('node.only_RSVP_for_yourself') : false
    elsif tagname == 'locked' && user.role != 'admin'
      errors ? I18n.t('node.only_admins_can_lock') : false
    elsif tagname.split(':')[0] == 'redirect' && Node.where(slug: tagname.split(':')[1]).length <= 0
      errors ? I18n.t('node.page_does_not_exist') : false
    elsif  tagname.split(':')[1] == "facebook"
      errors ? "This tag is used for associating a Facebook account. <a href='https://publiclab.org/wiki/oauth'>Click here to read more </a>" : false
    elsif  tagname.split(':')[1] == "github"
      errors ? "This tag is used for associating a Github account. <a href='https://publiclab.org/wiki/oauth'>Click here to read more </a>" : false
    elsif  tagname.split(':')[1] ==  "google_oauth2"
      errors ? "This tag is used for associating a Google account. <a href='https://publiclab.org/wiki/oauth'>Click here to read more </a>" : false
    elsif  tagname.split(':')[1] == "twitter"
      errors ? "This tag is used for associating a Twitter account. <a href='https://publiclab.org/wiki/oauth'>Click here to read more </a>" : false
    else
      true
    end
  end

  def replace(before, after, user)
    matches = latest.body.scan(before)
    if matches.length == 1
      revision = new_revision(uid: user.id,
                              body: latest.body.gsub(before, after))
      revision.save
    else
      false
    end
  end

  def is_liked_by(user)
    !NodeSelection.where(user_id: user.uid, nid: id, liking: true).empty?
  end

  def toggle_like(user)
    nodes = NodeSelection.where(nid: id, liking: true).count
    if is_liked_by(user)
      self.cached_likes = nodes - 1
    else
      self.cached_likes = nodes + 1
    end
  end

  def self.like(nid, user)
    # scope like variable outside the transaction
    like = nil
    count = nil

    ActiveRecord::Base.transaction do
      # Create the entry if it isn't already created.
      like = NodeSelection.where(user_id: user.uid,
                                 nid: nid).first_or_create
      like.liking = true
      node = Node.find(nid)
      if node.type == 'note' && !UserTag.exists?(node.uid, 'notify-likes-direct:false')
        SubscriptionMailer.notify_note_liked(node, like.user).deliver_now
      end
      count = 1
      node.toggle_like(like.user)
      # Save the changes.
      node.save!
      like.save!
    end
    count
  end

  def self.unlike(nid, user)
    like = nil
    count = nil

    ActiveRecord::Base.transaction do
      like = NodeSelection.where(user_id: user.uid,
                                 nid: nid).first_or_create
      like.liking = false
      count = -1
      node = Node.find(nid)
      node.toggle_like(like.user)
      node.save!
      like.save!
    end
    count
  end

  # status = 3 for draft nodes,visible to author only
  def draft
    self.status = 3
    save
    self
  end

  def draft_url
    @token = slug.split('token:').last
    url = 'https://publiclab.org/notes/show/' + nid.to_s + '/' + @token.to_s
  end
end
