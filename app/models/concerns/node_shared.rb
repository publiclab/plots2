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
        exclude = excluded_tagnames(tagname)
        tagname = featured_tagname(tagname)
      end

      nodes = nodes_by_tagname(tagname, 'note')
      nodes -= excluded_nodes(exclude, 'note') if exclude.present?

      output = initial_output_str(Regexp.last_match(1))
      output + data_string('thumbnail', tagname, nodes, 'notes')
    end
  end

  def self.nodes_thumbnail_grid(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[nodes\:grid\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil

      if tagname.include?('!')
        exclude = excluded_tagnames(tagname)
        tagname = featured_tagname(tagname)
      end

      nodes = nodes_by_tagname(tagname, ['note','page'])
      nodes -= excluded_nodes(exclude, 'page') if exclude.present?
      nodes -= excluded_nodes(exclude, 'note') if exclude.present?

      output = initial_output_str(Regexp.last_match(1))
      output + data_string('thumbnail', tagname, nodes, 'nodes')
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

  def self.simple_data_grapher(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[simple-data-grapher\:(\S+)\]/) do |_tagname|
      ids = Regexp.last_match(2)
      a = ActionController::Base.new
      randomSeed = rand(1000).to_s
      output = a.render_to_string(template: "grids/_simple-data-grapher",
                                  layout:   false,
                                  locals: {
                                    ids: ids,
                                    randomSeed: randomSeed,
                                    idName: 'sdg-graph-' + randomSeed,
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
        exclude = excluded_tagnames(tagname)
        tagname = featured_tagname(tagname)
      end

      nodes = nodes_by_tagname(tagname, 'note')
      nodes -= excluded_nodes(exclude, 'note') if exclude.present?

      output = initial_output_str(Regexp.last_match(1))
      output + data_string('notes', tagname, nodes, 'notes')
    end
  end

  def self.nodes_grid(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[nodes\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil

      if tagname.include?('!')
        exclude = excluded_tagnames(tagname)
        tagname = featured_tagname(tagname)
      end

      nodes = nodes_by_tagname(tagname, %w(page note))
      nodes -= excluded_nodes(exclude) if exclude.present?

      output = initial_output_str(Regexp.last_match(1))
      output + data_string('nodes', tagname, nodes, 'nodes')
    end
  end

  # rubular regex: http://rubular.com/r/hBEThNL4qd
  def self.questions_grid(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[questions\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil

      if tagname.include?('!')
        exclude = excluded_tagnames(tagname)
        tagname = featured_tagname(tagname)
      end

      nodes = nodes_by_tagname("question:#{tagname}", 'note')
      nodes -= excluded_nodes(exclude, 'note') if exclude.present?

      output = initial_output_str(Regexp.last_match(1))
      output + data_string('notes', tagname, nodes, 'questions')
    end
  end

  def self.activities_grid(body)
    body.gsub(/(?<![\>`])(\<p\>)?\[activities\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil

      if tagname.include?('!')
        exclude = excluded_tagnames(tagname)
        tagname = featured_tagname(tagname)
      end

      pinned = pinned_nodes("activity:" + tagname)
              .where("node.type = 'note'")
      nodes = pinned + Node.activities(tagname)
                           .order('node.cached_likes DESC')
                           .where.not(nid: pinned.collect(&:nid)) # don't include pinned twice
      nodes -= excluded_nodes(exclude, 'note') if exclude.present?

      output = initial_output_str(Regexp.last_match(1))
      output + data_string('notes', tagname, nodes, 'activity')
    end
  end

  def self.upgrades_grid(body)
    body.gsub(/(?<![\>`])(\<p\>)?\[upgrades\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil

      if tagname.include?('!')
        exclude = excluded_tagnames(tagname)
        tagname = featured_tagname(tagname)
      end

      pinned = pinned_nodes("upgrade:" + tagname)
               .where("node.type = 'note'")
      nodes = pinned + Node.upgrades(tagname)
                           .order('node.cached_likes DESC')
                           .where.not(nid: pinned.collect(&:nid)) # don't include pinned twice
      nodes -= excluded_nodes(exclude, 'note') if exclude.present?

      output = initial_output_str(Regexp.last_match(1))
      output + data_string('notes', tagname, nodes, 'upgrades')
    end
  end

  # Blank map loaded only , markers will be loaded using API call .
  def self.notes_map(body)
    body.gsub(/(?<![\>`])(\<p\>)?\[map\:content\:(\S+)\:(\S+)\]/) do |_tagname|
      lat = Regexp.last_match(2)
      lon = Regexp.last_match(3)
      tagname = nil
      
      map_data_string(lat, lon, tagname, "plainInlineLeaflet")
    end
  end

  def self.notes_map_by_tag(body)
    body.gsub(/(?<![\>`])(\<p\>)?\[map\:tag\:(\S+)\:(\S+)\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      lat = Regexp.last_match(3)
      lon = Regexp.last_match(4)

      map_data_string(lat, lon, tagname, "plainInlineLeaflet")
    end
  end

  # in our interface, "users" are known as "people" because it's more human
  def self.people_map(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[map\:people\:(\S+)\:(\S+)\]/) do |_tagname|
      lat = Regexp.last_match(2)
      lon = Regexp.last_match(3)
      tagname = nil

      map_data_string(lat, lon, tagname, "peopleLeaflet")
    end
  end

  # [map:layers:other_inline_layer:_latitude_:_longitude:skytruth,mapknitter]
  # [map:layers::_latitude_:_longitude:skytruth,mapknitter]
  def self.layers_map(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[map\:layers\:(\w*)\:(\S+)\:(\S+)\:(\w+)((\,\w+)*)\]/) do |_tagname|
      mainLayer = Regexp.last_match(2)
      lat = Regexp.last_match(3)
      lon = Regexp.last_match(4)
      primaryLayer =  Regexp.last_match(5).to_s
      secondaryLayers = Regexp.last_match(6).to_s
      unless secondaryLayers.nil?
        primaryLayer += secondaryLayers
      end

      map_data_string(lat, lon, primaryLayer, "inlineLeaflet", mainLayer)
    end
  end

  # [map:layers:tag:infragram:23:77:skyTruth,mapKnitter]
  def self.tag_layers_map(body, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[map\:layers\:tag\:(\w+)\:(\S+)\:(\S+)\:(\w+)((\,\w+)*)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      lat = Regexp.last_match(3)
      lon = Regexp.last_match(4)
      primaryLayer =  Regexp.last_match(5).to_s
      secondaryLayers = Regexp.last_match(6).to_s
      unless secondaryLayers.nil?
        primaryLayer += secondaryLayers
      end

      map_data_string(lat, lon, primaryLayer, "inlineLeaflet", tagname)
    end
  end

  # in our interface, "users" are known as "people" because it's more human
  def self.people_grid(body, current_user = nil, _page = 1)
    body.gsub(/(?<![\>`])(\<p\>)?\[people\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      exclude = nil

      if tagname.include?('!')
        exclude = excluded_tagnames(tagname)
        tagname = featured_tagname(tagname)
      end

      users = users_by_tagname(tagname)
      users -= excluded_users(exclude) if exclude.present?

      output = initial_output_str(Regexp.last_match(1))
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
        exclude = excluded_tagnames(tagname)
        tagname = featured_tagname(tagname)
      end

      nodes = nodes_by_tagname(tagname, 'page')
      nodes -= excluded_nodes(exclude, 'page') if exclude.present?

      output = initial_output_str(Regexp.last_match(1))
      output + data_string('wikis', tagname, nodes, 'wikis')
    end
  end

  def self.pinned_nodes(tagname)
    Node.where(status: 1)
        .includes(:revision, :tag)
        .references(:term_data, :node_revisions)
        .where('term_data.name = ?', "pin:#{tagname}")
  end

  def self.excluded_tagnames(tagname)
    tagname.split('!') - [tagname.split('!').first]
  end

  def self.featured_tagname(tagname)
    tagname.split('!').first
  end

  def self.excluded_nodes(exclude, type = nil)
    if type
      Node.where(status: 1, type: type)
          .includes(:revision, :tag)
          .references(:node_revisions, :term_data)
          .where('term_data.name IN (?)', exclude)
    else
      Node.where(status: 1)
          .includes(:revision, :tag)
          .references(:node_revisions, :term_data)
          .where('term_data.name IN (?)', exclude)
    end
  end

  def self.initial_output_str(last_match)
    if last_match == '<p>'
      '<p>'
    else
      ''
    end
  end

  def self.data_string(view, tagname, nodes, type)
    a = ActionController::Base.new
    grid = (view == 'thumbnail' ? "#{type}-grid-thumbnail" : "#{type}-grid-")

    a.render_to_string(template: "grids/_#{view}",
                       layout:   false,
                       locals:   {
                         tagname: tagname,
                         randomSeed: rand(1000).to_s,
                         className: "#{grid}#{tagname.parameterize}",
                         nodes: nodes,
                         type: type
                       })
  end

  def self.map_data_string(lat, lon, tagname, template, mainLayer = nil)
    a = ActionController::Base.new

    locals_data = if template == "plainInlineLeaflet"
                    { lat: lat, lon: lon, tagname: tagname.to_s }
                  elsif template == "inlineLeaflet"
                    { lat: lat, lon: lon, layers: tagname.to_s, mainLayer: mainLayer }
                  else
                    { lat: lat, lon: lon, people: true,
                      url_hash: 0, tag_name: false }
                  end

    output = a.render_to_string(template: "map/_#{template}",
                                layout: false,
                                locals: locals_data)
    output
  end

  def self.users_by_tagname(tagname)
    User.where(status: 1)
        .includes(:user_tags)
        .references(:user_tags)
        .where('user_tags.value = ?', tagname)
  end

  def self.excluded_users(exclude)
    User.where(status: 1)
        .includes(:user_tags)
        .references(:user_tags)
        .where('user_tags.value IN (?)', exclude)
  end

  def self.nodes_by_tagname(tagname, type, limit: 24)
    if type.is_a? Array
      type1 = type.first
      type2 = type.last
      pinned = pinned_nodes(tagname)
               .where('node.type = ? OR node.type = ?', type1, type2)

      pinned + Node.where(status: 1)
                   .where('node.type = ? OR node.type = ?', type1, type2)
                   .joins(:revision,:tag)
                   .where('term_data.name = ?', tagname)
                   .order('node.changed DESC')
                   .limit(limit)
                   .where.not(nid: pinned.collect(&:nid)) # don't include pinned items twice
    else
      pinned = pinned_nodes(tagname)
               .where('node.type = ?', type)

      pinned + Node.where(status: 1)
                   .where('node.type = ?', type)
                   .joins(:tag)
                   .where('term_data.name = ?', tagname)
                   .order('node.changed DESC')
                   .limit(limit)
                   .where.not(nid: pinned.collect(&:nid)) # don't include pinned items twice
    end
  end
end
