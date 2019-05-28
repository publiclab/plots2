module NodeShared
  extend ActiveSupport::Concern

  def likes
    cached_likes
  end

  def liked_by(uid)
    likers.collect(&:uid).include?(uid)
  end
  
  def self.button(body)
    body.gsub(/(?<![\>`])(\<p\>)?\[button\:(.+)\:(\S+)\]/) do |_tagname|
      btnText = Regexp.last_match(2)
      btnHref = Regexp.last_match(3)
      return '<a class="btn btn-primary inline-button-shortcode" href="' + btnHref + '">' + btnText + '</a>'
    end
  end

  def self.notes_thumbnail_grid(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[notes\:grid\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil
      if tagname.include?('!')
        exclude = tagname.split('!') - [tagname.split('!').first]
        tagname = tagname.split('!').first
      end

      pinned = pinned_nodes(tagname)
        .where("node.type = 'note'")
      nodes = pinned + Node.where(status: 1, type: 'note')
                  .includes(:revision, :tag)
                  .references(:term_data, :node_revisions)
                  .where('term_data.name = ?', tagname)
                  .order('node_revisions.timestamp DESC')
                  .where.not(nid: pinned.collect(&:nid)) # don't include pinned items twice

      if exclude.present?
        exclude = Node.where(status: 1, type: 'note')
                  .includes(:revision, :tag)
                  .references(:node_revisions, :term_data)
                  .where('term_data.name IN (?)', exclude)
        nodes -= exclude
      end
      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new
      output += a.render_to_string(template: "grids/_thumbnail",
                                   layout:   false,
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'notes-grid-thumbnail' + tagname.parameterize,
                                     nodes: nodes,
                                     type: "notes"
                                   })
      output
    end
  end

  # rubular regex: http://rubular.com/r/hBEThNL4qd
  def self.graph_grid(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[graph\:(\S+)\]/) do |_tagname|
      url = Regexp.last_match(2)
      a = ActionController::Base.new
      randomSeed = rand(1000).to_s
      output = a.render_to_string(template: "grids/_graph",
                                  layout:   false,
                                  locals:   {
                                    url: url,
                                    randomSeed: randomSeed,
                                    idName: 'graph-grid-' + randomSeed,
                                    type: "graph"
                                  })
      output
    end
  end

  # rubular regex: http://rubular.com/r/hBEThNL4qd
  def self.notes_grid(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[notes\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil
      if tagname.include?('!')
        exclude = tagname.split('!') - [tagname.split('!').first]
        tagname = tagname.split('!').first
      end

      pinned = pinned_nodes(tagname)
        .where("node.type = 'note'")
      nodes = pinned + Node.where(status: 1, type: 'note')
                  .includes(:revision, :tag)
                  .references(:term_data, :node_revisions)
                  .where('term_data.name = ?', tagname)
                  .order('node_revisions.timestamp DESC')
                  .where.not(nid: pinned.collect(&:nid)) # don't include pinned items twice

      if exclude.present?
        exclude = Node.where(status: 1, type: 'note')
                  .includes(:revision, :tag)
                  .references(:node_revisions, :term_data)
                  .where('term_data.name IN (?)', exclude)
        nodes -= exclude
      end
      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new
      output += a.render_to_string(template: "grids/_notes",
                                   layout:   false,
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'notes-grid-' + tagname.parameterize,
                                     nodes: nodes,
                                     type: "notes"
                                   })
      output
    end
  end

  def self.nodes_grid(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[nodes\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil
      if tagname.include?('!')
        exclude = tagname.split('!') - [tagname.split('!').first]
        tagname = tagname.split('!').first
      end

      pinned = pinned_nodes(tagname)
        .where("node.type = 'page' OR node.type = 'note'")
      nodes = pinned + Node.where(status: 1)
                  .where("node.type = 'page' OR node.type = 'note'")
                  .includes(:revision, :tag)
                  .references(:term_data, :node_revisions)
                  .where('term_data.name = ?', tagname)
                  .order('node_revisions.timestamp DESC')
                  .where.not(nid: pinned.collect(&:nid)) # don't include pinned items twice

      if exclude.present?
        exclude = Node.where(status: 1)
                  .includes(:revision, :tag)
                  .references(:node_revisions, :term_data)
                  .where('term_data.name IN (?)', exclude)
        nodes -= exclude
      end
      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new
      output += a.render_to_string(template: "grids/_nodes",
                                   layout:   false,
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'nodes-grid-' + tagname.parameterize,
                                     nodes: nodes,
                                     type: "nodes"
                                   })
      output
    end
  end

  # rubular regex: http://rubular.com/r/hBEThNL4qd
  def self.questions_grid(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[questions\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil
      if tagname.include?('!')
        exclude = tagname.split('!') - [tagname.split('!').first]
        tagname = tagname.split('!').first
      end
      pinned = pinned_nodes("question:" + tagname)
        .where("node.type = 'note'")
      nodes = pinned + Node.where(status: 1, type: 'note')
                  .includes(:revision, :tag)
                  .references(:node_revisions, :term_data)
                  .where('term_data.name = ?', "question:#{tagname}")
                  .order('node_revisions.timestamp DESC')
                  .where.not(nid: pinned.collect(&:nid)) # don't include pinned items twice

      if exclude.present?
        exclude = Node.where(status: 1, type: 'note')
                  .includes(:revision, :tag)
                  .references(:node_revisions, :term_data)
                  .where('term_data.name IN (?)', exclude)
        nodes -= exclude
      end
      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new
      output += a.render_to_string(template: "grids/_notes",
                                   layout:   false,
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'questions-grid-' + tagname.parameterize,
                                     nodes: nodes,
                                     type: "questions"
                                   })
      output
    end
  end

  def self.activities_grid(body)
    body.gsub(/(?<![\>`])(\<p\>)?\[activities\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil
      if tagname.include?('!')
        exclude = tagname.split('!') - [tagname.split('!').first]
        tagname = tagname.split('!').first
      end
      pinned = pinned_nodes("activity:" + tagname)
        .where("node.type = 'note'")
      nodes = pinned + Node.activities(tagname)
                  .order('node.cached_likes DESC')
                  .where.not(nid: pinned.collect(&:nid)) # don't include pinned items twice

      if exclude.present?
        exclude = Node.where(status: 1, type: 'note')
                  .includes(:revision, :tag)
                  .references(:node_revisions, :term_data)
                  .where('term_data.name IN (?)', exclude)
        nodes -= exclude
      end
      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new
      output += a.render_to_string(template: "grids/_notes",
                                   layout:   false,
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'activity-grid-' + tagname.parameterize,
                                     nodes: nodes,
                                     type: "activity"
                                   })
      output
    end
  end

  def self.upgrades_grid(body)
    body.gsub(/(?<![\>`])(\<p\>)?\[upgrades\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil
      if tagname.include?('!')
        exclude = tagname.split('!') - [tagname.split('!').first]
        tagname = tagname.split('!').first
      end
      pinned = pinned_nodes("upgrade:" + tagname)
        .where("node.type = 'note'")
      nodes = pinned + Node.upgrades(tagname)
                  .order('node.cached_likes DESC')
                  .where.not(nid: pinned.collect(&:nid)) # don't include pinned items twice

      if exclude.present?
        exclude = Node.where(status: 1, type: 'note')
                  .includes(:revision, :tag)
                  .references(:node_revisions, :term_data)
                  .where('term_data.name IN (?)', exclude)
        nodes -= exclude
      end

      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new
      output += a.render_to_string(template: "grids/_notes",
                                   layout:   false,
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'upgrades-grid-' + tagname.parameterize,
                                     nodes: nodes,
                                     type: "upgrades"
                                   })
      output
    end
  end

  # Blank map loaded only , markers will be loaded using API call .
  def self.notes_map(body)
    body.gsub(/(?<![\>`])(\<p\>)?\[map\:content\:(\S+)\:(\S+)\]/) do |_tagname|
      lat = Regexp.last_match(2)
      lon = Regexp.last_match(3)
      tagname = nil
      a = ActionController::Base.new
      output = a.render_to_string(template: "map/_leaflet",
                                  layout:   false,
                                  locals:   {
                                    lat: lat,
                                    lon: lon,
                                    tagname: tagname
                                  })
      output
    end
  end

  def self.notes_map_by_tag(body)
    body.gsub(/(?<![\>`])(\<p\>)?\[map\:tag\:(\S+)\:(\S+)\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      lat = Regexp.last_match(3)
      lon = Regexp.last_match(4)
      a = ActionController::Base.new
      output = a.render_to_string(template: "map/_leaflet",
                                  layout:   false,
                                  locals:   {
                                    lat: lat,
                                    lon: lon,
                                    tagname: tagname.to_s
                                  })
      output
    end
  end

  # in our interface, "users" are known as "people" because it's more human
  def self.people_map(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[map\:people\:(\S+)\:(\S+)\]/) do |_tagname|
      lat = Regexp.last_match(2)
      lon = Regexp.last_match(3)

      a = ActionController::Base.new
      output = a.render_to_string(template: "map/_peopleLeaflet",
                                  layout:   false,
                                  locals:   {
                                    lat: lat,
                                    lon: lon,
                                    people: true,
                                    url_hash: 0,
                                    tag_name: false
                                  })
      output
    end
  end

  # in our interface, "users" are known as "people" because it's more human
  def self.people_grid(body, current_user = nil, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[people\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil
      if tagname.include?('!')
        exclude = tagname.split('!') - [tagname.split('!').first]
        tagname = tagname.split('!').first
      end

      users = User.where(status: 1)
                  .includes(:user_tags)
                  .references(:user_tags)
                  .where('user_tags.value = ?', tagname)

      if exclude.present?
        exclude = User.where(status: 1)
                  .includes(:user_tags)
                  .references(:user_tags)
                  .where('user_tags.value IN (?)', exclude)
        users -= exclude
      end

      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new
      output += a.render_to_string(template: "grids/_people",
                                   layout:   false,
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'people-grid-' + tagname.parameterize,
                                     current_user: current_user,
                                     users: users
                                   })
      output
    end
  end

  def self.wikis_grid(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[wikis\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil
      if tagname.include?('!')
        exclude = tagname.split('!') - [tagname.split('!').first]
        tagname = tagname.split('!').first
      end

      pinned = pinned_nodes(tagname)
        .where("node.type = 'page'")
      nodes = pinned + Node.where(status: 1, type: 'page')
                  .includes(:revision, :tag)
                  .references(:term_data, :node_revisions)
                  .where('term_data.name = ?', tagname)
                  .order('node_revisions.timestamp DESC')
                  .where.not(nid: pinned.collect(&:nid)) # don't include pinned items twice

      if exclude.present?
        exclude = Node.where(status: 1, type: 'page')
                  .includes(:revision, :tag)
                  .references(:node_revisions, :term_data)
                  .where('term_data.name IN (?)', exclude)
        nodes -= exclude
      end

      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new
      output += a.render_to_string(template: "grids/_wikis",
                                   layout:   false,
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'wikis-grid-' + tagname.parameterize,
                                     nodes: nodes,
                                     type: "wikis"
                                   })
      output
    end
  end

  def self.pinned_nodes(tagname)
    Node.where(status: 1)
        .includes(:revision, :tag)
        .references(:term_data, :node_revisions)
        .where('term_data.name = ?', "pin:#{tagname}")
  end
end
