module NodeTagging
  extend ActiveSupport::Concern

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
     tags = NodeTag.where(nid: id)
       .where(tid: tids)
       .joins(:tag)
       .joins("LEFT OUTER JOIN tag_selections ON term_data.tid = tag_selections.tid") 
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

  def barnstar
    power_tag_objects('barnstar').first
  end

  def barnstars
    power_tag_objects('barnstar')
  end

  def add_barnstar(tagname, giver)
    add_tag(tagname, giver)
    CommentMailer.notify_barnstar(giver, self).deliver_later
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
            subtags['h2s'] = 'hydrogen-sulfide'
            subtags['near-infrared-camera'] = 'multispectral-imaging'
            subtags['infragram'] = 'multispectral-imaging'
            subtags['odors'] = 'odor'
            subtags['oil'] = 'oil-and-gas'
            subtags['purple-air'] = 'purpleair'
            subtags['reagent'] = 'reagents'
            subtags['spectrometer'] = 'spectrometry'
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
              # send email notification if there are subscribers, status is OK, and less than 1 month old
              isStatusValid = status == 3 || status == 4
              isMonthOld = created < (DateTime.now - 1.month).to_i
              unless tag.subscriptions.empty? || isStatusValid || !isMonthOld
                SubscriptionMailer.notify_tag_added(self, tag, user).deliver_later
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
    elsif tagname == 'locked' && !user.can_moderate?
      errors ? I18n.t('node.only_admins_can_lock') : false
    elsif tagname == 'blog' && user.basic_user?
      errors ? 'Only moderators or admins can use this tag.' : false
    elsif tagname.split(':')[0] == 'redirect' && Node.where(slug: one_split).size <= 0
      errors ? I18n.t('node.page_does_not_exist') : false
    elsif socials[one_split&.to_sym].present?
      errors ? "This tag is used for associating a #{socials[one_split.to_sym]} account. <a href='https://publiclab.org/wiki/oauth'>Click here to read more </a>" : false
    elsif user.first_time_poster && !(user.username == self.author.username || self.coauthors&.exists?(username: user.username) || (['admin', 'moderator'].include? user.role))
      errors ? "Adding tags to other people\u2019s posts is not available to you until your own first post has been approved by site moderators" : false
    else
      true
    end
  end

  def tag_activity(cid)
    tids = tag.pluck(:tid)
    comment_id = "c#{cid}"
    Tag.update_tags_activity(tids, comment_id)
  end
end
