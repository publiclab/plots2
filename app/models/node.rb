class UniqueUrlValidator < ActiveModel::Validator
  def validate(record)
    if record.title.blank?
      record.errors[:base] << "You must provide a title."
      # otherwise the below title uniqueness check fails, as title presence validation doesn't run until after
    elsif record.type == 'page'
      array = %w(create edit update delete new)
      if array.include? record.title.downcase
        record.errors[:base] << "You may not use the title '#{record.title}'"
      end
    else
      if !Node.where(path: record.generate_path).first.nil? && record.type == 'note'
        record.errors[:base] << 'You have already used this title.'
      end
    end
  end
end

class Node < ActiveRecord::Base
  extend RawStats
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

    # We can drastically have this simplified using one DB
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      if order == :natural
        query = connection.quote(query.to_s)
        nids = if type == :boolean
                 # Query is done as a boolean full-text search. More info here: https://dev.mysql.com/doc/refman/5.5/en/fulltext-boolean.html
                 Revision.select("node_revisions.nid, node_revisions.body, node_revisions.title, MATCH(node_revisions.body, node_revisions.title) AGAINST(#{query} IN BOOLEAN MODE) AS score")
                   .where("MATCH(node_revisions.body, node_revisions.title) AGAINST(#{query} IN BOOLEAN MODE)")
                   .limit(limit)
                   .distinct
                   .collect(&:nid)
               else
                 Revision.select("node_revisions.nid, node_revisions.body, node_revisions.title, MATCH(node_revisions.body, node_revisions.title) AGAINST(#{query} IN NATURAL LANGUAGE MODE) AS score")
                   .where("MATCH(node_revisions.body, node_revisions.title) AGAINST(#{query} IN NATURAL LANGUAGE MODE)")
                   .limit(limit)
                   .distinct
                   .collect(&:nid)
               end
        where(nid: nids, status: 1)
      elsif order == :natural_titles_only
        Revision.select("node_revisions.nid, node_revisions.body, node_revisions.title, MATCH(node_revisions.title) AGAINST(#{query} IN NATURAL LANGUAGE MODE) AS score")
          .where("MATCH(node_revisions.body, node_revisions.title) AGAINST(#{query} IN NATURAL LANGUAGE MODE)")
          .limit(limit)
          .distinct
          .collect(&:nid)
        where(nid: nids, status: 1)
      elsif
        nids = Revision.where('MATCH(node_revisions.body, node_revisions.title) AGAINST(?)', query).collect(&:nid)

        tnids = Tag.find_nodes_by_type(query, %w(note page)).collect(&:nid) # include results by tag
        where(nid: nids + tnids, status: 1)
          .order(order_param)
          .limit(limit)
          .distinct
      end
    else
      Node.limit(limit)
        .where('title LIKE ?', '%' + query + '%')
        .where(status: 1)
        .order(order_param)
    end
  end

  def updated_month
    updated_at.strftime('%B %Y')
  end

  has_many :revision, foreign_key: 'nid', dependent: :destroy
  has_many :drupal_upload, foreign_key: 'nid' # , dependent: :destroy # re-enable in Rails 5
  has_many :drupal_files, through: :drupal_upload
  has_many :node_tag, foreign_key: 'nid' # , dependent: :destroy # re-enable in Rails 5
  has_many :tag, through: :node_tag
  has_many :comments, foreign_key: 'nid', dependent: :destroy # re-enable in Rails 5
  has_many :drupal_content_type_map, foreign_key: 'nid' # , dependent: :destroy # re-enable in Rails 5
  has_many :drupal_content_field_mappers, foreign_key: 'nid' # , dependent: :destroy # re-enable in Rails 5
  has_many :drupal_content_field_map_editor, foreign_key: 'nid' # , dependent: :destroy # re-enable in Rails 5
  has_many :images, foreign_key: :nid
  has_many :node_selections, foreign_key: :nid, dependent: :destroy
  has_many :answers, foreign_key: :nid, dependent: :destroy

  belongs_to :user, foreign_key: 'uid'

  validates :title, presence: true, length: { minimum: 3 }
  validates_with UniqueUrlValidator, on: :create

  scope :published, -> { where(status: 1) }
  scope :past_week, -> { published.where("created > ?", (Time.now - 7.days).to_i) }
  scope :past_month, -> { published.where("created > ?", (Time.now - 1.months).to_i) }
  scope :past_year, -> { published.where("created > ?", (Time.now - 1.years).to_i) }

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

  def has_a_tag(name)
    return tags.where(name: name).size.positive?
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
  # or, we should refactor to use node.created instead of Time.now
  def generate_path
    time = Time.now.strftime('%m-%d-%Y')

    case type
    when "note"
      username = User.find_by(id: uid).name # name? or username?
      "/notes/#{username}/#{time}/#{title.parameterize}"
    when "map"
      "/map/#{title.parameterize}/#{time}"
    when "feature"
      "/feature/#{title.parameterize}"
    when "page"
      "/wiki/#{title.parameterize}"
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

  is_impressionable counter_cache: true, column_name: :views, unique: :ip_address

  def self.weekly_tallies(type = 'note', span = 52, time = Time.now)
    weeks = {}
    (0..span).each do |week|
      weeks[span - week] = Node.select(:created)
                               .where(type:    type,
                                      status:  1,
                                      created: time.to_i - week.weeks.to_i..time.to_i - (week - 1).weeks.to_i)
                               .size
    end
    weeks
  end

  def self.contribution_graph_making(type = 'note', start = Time.now - 1.year, fin = Time.now)
    date_hash = {}
    week = start.to_date.step(fin.to_date, 7).count

    while week >= 1
      month = (fin - (week * 7 - 1).days)
      range = (fin.to_i - week.weeks.to_i)..(fin.to_i - (week - 1).weeks.to_i)

      weekly_nodes = Node.published.select(:created)
                    .where(type: type,
                    created: range)
                    .size
      date_hash[month.to_f * 1000] = weekly_nodes
      week -= 1
    end
    date_hash
  end

  def self.frequency(type, starting, ending)
    weeks = (ending.to_date - starting.to_date).to_i / 7.0
    Node.published.select(%i(created type))
      .where(type: type, created: starting.to_i..ending.to_i)
      .size / weeks
  end

  def notify
    if status == 4
      AdminMailer.notify_node_moderators(self).deliver_later!(wait_until: 24.hours.from_now)
    else
      SubscriptionMailer.notify_node_creation(self).deliver_later!
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

  def flag_node
    self.flag += 1
    save
    self
  end

  def unflag_node
    self.flag = 0
    save
    self
  end

  def files
    drupal_files
  end

  def answered
    answers&.size&.positive?
  end

  def has_accepted_answers
    answers.where(accepted: true).size.positive?
  end

  # users who like this node
  def likers
    node_selections
      .joins(:user)
      .references(:rusers)
      .where(liking: true)
      .where('rusers.status': 1)
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

  def author
    User.find(uid)
  end

  def authors
    revisions.collect(&:author).uniq
  end

  def coauthors
    User.where(username: power_tags('with')) if has_power_tag('with')
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

  def summary
    body.lines.first
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
    match = latest&.render_body&.scan(/<img(.*?)\/>/)&.first&.first
    match&.split('src="')&.last&.split('"')&.first
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
        .size
  end

  # power tags have "key:value" format, and should be searched with a "key:*" wildcard
  def has_power_tag(key)
    !power_tag(key).blank?
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
  def power_tags(tagname)
    tags = []
    power_tag_objects(tagname).each do |nt|
      tags << nt.name.gsub(tagname + ':', '')
    end
    tags
  end

  # returns all power tag results as whole community_tag objects
  def power_tag_objects(tagname = nil)
    tags = Tag.includes(:node_tag)
              .references(:community_tags)
              .where('community_tags.nid = ?', id)
    if tagname
      tags = tags.where('name LIKE ?', tagname + ':%')
    else
      tags = tags.where('name LIKE ?', '%:%') # any powertag
    end
    tids = tags.collect(&:tid)
    NodeTag.where('nid = ? AND tid IN (?)', id, tids)
  end

  # return whole community_tag objects but no powertags or "event"
  def normal_tags(order = :none)
    all_tags = tags.select { |tag| !tag.name.include?(':') }
    tids = all_tags.collect(&:tid)
    if order == :followers
      tags = NodeTag.where('nid = ? AND community_tags.tid IN (?)', id, tids)
                    .left_outer_joins(:tag, :tag_selections)
                    .order(Arel.sql('count(tag_selections.user_id) DESC'))
                    .group('community_tags.tid, community_tags.uid, community_tags.date, community_tags.created_at, community_tags.updated_at')
    else
      tags = NodeTag.where('nid = ? AND tid IN (?)', id, tids)
    end
    tags
  end

  def location_tags
    if lat && lon && place
      power_tag_objects('lat') + power_tag_objects('lon') + power_tag_objects('place')
    elsif lat && lon
      power_tag_objects('lat') + power_tag_objects('lon')
    else
      []
    end
  end

  # access a tagname /or/ tagname ending in wildcard such as "tagnam*"
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
    []
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

  def zoom
    if has_power_tag('zoom')
      power_tag('zoom').to_f
    else
      false
    end
  end

  def place
    if has_power_tag('place')
      power_tag('place')
    else
      false
    end
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

  def self.for_tagname_and_type(tagname, type = 'note', options = {})
    return Node.for_wildcard_tagname_and_type(tagname, type) if options[:wildcard]

    return Node.for_question_tagname_and_type(tagname, type) if options[:question]

    Node.where(status: 1, type: type)
      .includes(:revision, :tag)
      .references(:term_data, :node_revisions)
      .where('term_data.name = ? OR term_data.parent = ?', tagname, tagname)
  end

  def self.for_wildcard_tagname_and_type(tagname, type = 'note')
    search_term = tagname[0..-2] + '%'
    Node.where(status: 1, type: type)
      .includes(:revision, :tag, :answers)
      .references(:term_data, :node_revisions)
      .where('term_data.name LIKE (?) OR term_data.parent LIKE (?)', search_term, search_term)
  end

  def self.for_question_tagname_and_type(tagname, type = 'note')
    other_tag = tagname.include?("question:") ? tagname.split(':')[1] : "question:#{tagname}"
    Node.where(status: 1, type: type)
      .includes(:revision, :tag)
      .references(:term_data, :node_revisions)
      .where('term_data.name = ? OR term_data.name = ? OR term_data.parent = ?', tagname, other_tag, tagname)
  end

  # ============================================
  # Automated constructors for associated models

  def add_comment(params = {})
    thread = !comments.empty? && !comments.last.nil? ? comments.last.next_thread : '01/'
    comment_via_status = params[:comment_via].nil? ? 0 : params[:comment_via].to_i
    user = User.find(params[:uid])
    status = user.first_time_poster && user.first_time_commenter ? 4 : 1
    c = Comment.includes(:node).new(pid: 0,
                    nid: nid,
                    uid: params[:uid],
                    subject: '',
                    hostname: '',
                    comment: params[:body],
                    status: status,
                    format: 1,
                    thread: thread,
                    timestamp: DateTime.now.to_i,
                    comment_via: comment_via_status,
                    message_id: params[:message_id],
                    tweet_id: params[:tweet_id])
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
    author = User.find(params[:uid])
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
        # prevent vid non-unique bug in https://github.com/publiclab/plots2/issues/7062
        raise ActiveRecord::Rollback if !node.valid? || node.vid == 0
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
    add_tag(tagname, giver)
    CommentMailer.notify_barnstar(giver, self).deliver_now
  end

  def add_tag(tagname, user)
    if user.status == 1
      tagname = tagname.downcase
      unless has_tag_without_aliasing(tagname)
        saved = false
        table_updated = false
        tag = Tag.find_by(name: tagname) || Tag.new(vid:         3, # vocabulary id; 1
                                                  name:        tagname,
                                                  description: '',
                                                  weight:      0)

        ActiveRecord::Base.transaction do
          if tag.valid?
            key = tag.name.split(':')[0]
            value = tag.name.split(':')[1]
            # add base tags:
            if ['question', 'upgrade', 'activity'].include?(key)
              add_tag(value, user)
            end
            # add sub-tags:
            subtags = {}
            subtags['pm'] = 'particulate-matter'
            if subtags.include?(key)
              add_tag(subtags[key], user)
            end
            # parse date tags:
            if key == 'date'
              begin
                DateTime.strptime(value, '%m-%d-%Y').to_date.to_s(:long)
              rescue StandardError
                return [false, tag.destroy]
              end
            end
            tag.save!
            node_tag = NodeTag.new(tid: tag.id,
                                 uid: user.uid,
                                 date: DateTime.now.to_i,
                                 nid: id)

            # Adding lat/lon values into node table
            if key == 'lat'
              tagvalue = value
              table_updated = update_attributes(latitude: tagvalue, precision: decimals(tagvalue).to_s)
            elsif key == 'lon'
              tagvalue = value
              table_updated = update_attributes(longitude: tagvalue)
            end

            if node_tag.save
              saved = true
              tag.run_count # update count of tag usage
              # send email notification if there are subscribers, status is OK, and less than 1 month old
              isStatusValid = status == 3 || status == 4
              isMonthOld = created < (DateTime.now - 1.month).to_i
              unless tag.subscriptions.empty? || isStatusValid || !isMonthOld
                SubscriptionMailer.notify_tag_added(self, tag, user).deliver_now
              end
            else
              saved = false
              tag.destroy
            end
          end
        end
        return [saved, tag, table_updated]
      end
    end
  end

  def decimals(number)
    !number.include?('.') ? 0 : number.split('.').last.size
  end

  def delete_coord_attribute(tagname)
    if tagname.split(':')[0] == "lat"
      update_attributes(latitude: nil, precision: nil)
    else
      update_attributes(longitude: nil)
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

    Node.where(type: 'note')
                .where('node.nid NOT IN (?)', nids)
  end

  def body_preview(length = 100)
    try(:latest).body_preview(length)
  end

  # so we can quickly fetch questions corresponding to this node
  # with node.questions
  def questions
    # override with a tag like `questions:h2s`
    tagname = if has_power_tag('questions')
                power_tag('questions')
              else
                slug_from_path
              end
    Node.where(status: 1, type: 'note')
        .includes(:revision, :tag)
        .references(:term_data)
        .where('term_data.name LIKE ?', "question:#{tagname}")
  end

  # all questions
  def self.questions
    Node.where(type: 'note')
        .joins(:tag)
        .where('term_data.name LIKE ?', 'question:%')
        .group('node.nid')
  end

  # all nodes with tagname
  def self.find_by_tag(tagname)
    Node.includes(:node_tag, :tag)
      .where('term_data.name = ? OR term_data.parent = ?', tagname, tagname)
      .references(:term_data, :node_tag)
  end

  # finds nodes by tag name, user id, and optional node type
  def self.find_by_tag_and_author(tagname, user_id, type = 'notes')

    node_type = 'note' if type == 'notes' || type == 'questions'
    node_type = 'page' if type == 'wiki'
    # node_type = 'map' if type == 'maps'  # Tag.tagged_nodes_by_author does not seem to work with maps, more testing required

    order = 'node_revisions.timestamp DESC'
    order = 'created DESC' if node_type == 'note'

    qids = Node.questions.where(status: 1).collect(&:nid)

    nodes = Tag.tagged_nodes_by_author(tagname, user_id)
      .includes(:revision)
      .references(:node_revisions)
      .where(status: 1, type: node_type)
      .order(order)

    nodes = nodes.where('node.nid NOT IN (?)', qids) if type == 'notes'
    nodes = nodes.where('node.nid IN (?)', qids) if type == 'questions'

    nodes
  end

  # so we can quickly fetch activities corresponding to this node
  # with node.activities
  def activities
    # override with a tag like `activities:h2s`
    tagname = if has_power_tag('activities')
                power_tag('activities')
              else
                slug_from_path
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
    tagname = if has_power_tag('upgrades')
                node.power_tag('upgrades')
              else
                slug_from_path
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
    one_split = tagname.split(':')[1]
    socials = { facebook: 'Facebook', github: 'Github', google_oauth2: 'Google', twitter: 'Twitter' }

    if tagname[0..4] == 'with:'
      if User.find_by_username_case_insensitive(one_split).nil?
        errors ? I18n.t('node.cannot_find_username') : false
      elsif author.uid != user.uid
        errors ? I18n.t('node.only_author_use_powertag') : false
      elsif one_split == user.username
        errors ? I18n.t('node.cannot_add_yourself_coauthor') : false
      else
        true
      end
    elsif tagname == 'format:raw' && user.role != 'admin'
      errors ? "Only admins may create raw pages." : false
    elsif tagname[0..4] == 'rsvp:' && user.username != one_split
      errors ? I18n.t('node.only_RSVP_for_yourself') : false
    elsif tagname == 'locked' && user.role != 'admin'
      errors ? I18n.t('node.only_admins_can_lock') : false
    elsif tagname == 'blog' && user.role != 'admin' && user.role != 'moderator'
      errors ? 'Only moderators or admins can use this tag.' : false
    elsif tagname.split(':')[0] == 'redirect' && Node.where(slug: one_split).size <= 0
      errors ? I18n.t('node.page_does_not_exist') : false
    elsif socials[one_split&.to_sym].present?
      errors ? "This tag is used for associating a #{socials[one_split.to_sym]} account. <a href='https://publiclab.org/wiki/oauth'>Click here to read more </a>" : false
    else
      true
    end
  end

  def replace(before, after, user)
    matches = latest.body.scan(before)
    if matches.size == 1
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
    nodes = NodeSelection.where(nid: id, liking: true).size
    self.cached_likes = if is_liked_by(user)
                          nodes - 1
                        else
                          nodes + 1
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
      if node.uid != user.id && UserTag.where(uid: user.id, value: ['notifications:all', 'notifications:like']).any?
        notification = Hash.new
        notification[:title] = "New Like on your research note"
        notification[:path] = node.path
        option = {
          body: "#{user.name} just liked your note #{node.title}",
          icon: "https://publiclab.org/logo.png"
        }
        notification[:option] = option
        User.send_browser_notification [user.id], notification
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

  def draft_url(base_url)
    token = slug.split('token:').last
    base_url + '/notes/show/' + nid.to_s + '/' + token
  end

  def comments_viewable_by(user)
    if user&.can_moderate?
      comments.where('status = 1 OR status = 4')
    elsif user
      comments.where('comments.status = 1 OR (comments.status = 4 AND comments.uid = ?)', user.uid)
    else
      comments.where(status: 1)
    end
  end

  def self.spam_graph_making(status)
    start = Time.now - 1.year
    fin = Time.now
    time_hash = {}
    week = start.to_date.step(fin.to_date, 7).count
    while week >= 1
      months = (fin - (week * 7 - 1).days)
      range = (fin.to_i - week.weeks.to_i)..(fin.to_i - (week - 1).weeks.to_i)
      nodes = Node.where(created: range).where(status: status).select(:created).size
      time_hash[months.to_f * 1000] = nodes
      week -= 1
    end
    time_hash
  end

  def notify_callout_users
    # notify mentioned users
    mentioned_users.each do |user|
      NodeMailer.notify_callout(self, user).deliver_now if user.username != author.username
    end
  end
end
