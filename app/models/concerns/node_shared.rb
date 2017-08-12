module NodeShared
  extend ActiveSupport::Concern

  def likes
    cached_likes
  end

  def liked_by(uid)
    likers.collect(&:uid).include?(uid)
  end

  # rubular regex: http://rubular.com/r/hBEThNL4qd
  def self.notes_grid(body, _page = 1)
    body.gsub(/[^\>`](\<p\>)?\[notes\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2).parameterize
      nodes = Node.where(status: 1, type: 'note')
                  .includes(:revision, :tag)
                  .where('term_data.name = ?', tagname)
                  .order('node_revisions.timestamp DESC')
      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new()
      output += a.render_to_string(template: "grids/_notes", 
                                   layout:   false, 
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'notes-grid-' + tagname,
                                     nodes: nodes,
                                     type: "notes"
                                   })
      output
    end
  end

  # rubular regex: http://rubular.com/r/hBEThNL4qd
  def self.questions_grid(body, _page = 1)
    body.gsub(/[^\>`](\<p\>)?\[questions\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2).parameterize
      nodes = Node.where(status: 1, type: 'note')
                  .includes(:revision, :tag)
                  .where('term_data.name = ?', "question:#{tagname}")
                  .order('node_revisions.timestamp DESC')
      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new()
      output += a.render_to_string(template: "grids/_notes", 
                                   layout:   false, 
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'questions-grid-' + tagname,
                                     nodes: nodes,
                                     type: "questions"
                                   })
      output
    end
  end

  def self.activities_grid(body)
    body.gsub(/[^\>`](\<p\>)?\[activities\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2).parameterize
      nodes = Node.activities(tagname)
                  .order('node.cached_likes DESC')
      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new()
      output += a.render_to_string(template: "grids/_notes", 
                                   layout:   false, 
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'activity-grid-' + tagname,
                                     nodes: nodes,
                                     type: "activity"
                                   })
      output
    end
  end

  def self.upgrades_grid(body)
    body.gsub(/[^\>`](\<p\>)?\[upgrades\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2).parameterize
      nodes = Node.upgrades(tagname)
                  .order('node.cached_likes DESC')
      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new()
      output += a.render_to_string(template: "grids/_notes", 
                                   layout:   false, 
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'upgrades-grid-' + tagname,
                                     nodes: nodes,
                                     type: "upgrades"
                                   })
      output
    end
  end

  def self.notes_map(body)
    body.gsub(/[^\>`](\<p\>)?\[map\:content\:(\S+)\:(\S+)\]/) do |_tagname|
      lat = Regexp.last_match(2)
      lon = Regexp.last_match(3)
      nids = NodeTag.joins(:tag)
                                   .where('name LIKE ?', 'lat:' + lat[0..lat.length - 2] + '%')
                                   .collect(&:nid)
      nids = nids || []
      items = Node.includes(:tag)
                  .where('node.nid IN (?) AND term_data.name LIKE ?', nids, 'lon:' + lon[0..lon.length - 2] + '%')
                  .limit(200)
                  .order('node.nid DESC')
      a = ActionController::Base.new()
      output = a.render_to_string(template: "map/_leaflet", 
                                  layout:   false, 
                                  locals:   {
                                    lat:   lat,
                                    lon:   lon,
                                    items: items
                                  }
               )
      output
    end
  end

  def self.notes_map_by_tag(body)
    body.gsub(/[^\>`](\<p\>)?\[map\:tag\:(\S+)\:(\S+)\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2)
      lat = Regexp.last_match(3)
      lon = Regexp.last_match(4)
      nids = NodeTag.joins(:tag)
                                   .where('term_data.name = ?', tagname)
                                   .collect(&:nid)
      nids = NodeTag.joins(:tag)
                                   .where(nid: nids)
                                   .where('name LIKE ?', 'lat:' + lat[0..lat.length - 2] + '%')
                                   .collect(&:nid)
      nids = nids || []
      items = Node.includes(:tag)
                  .where('node.nid IN (?) AND term_data.name LIKE ?', nids, 'lon:' + lon[0..lon.length - 2] + '%')
                  .limit(200)
                  .order('node.nid DESC')
      a = ActionController::Base.new()
      output = a.render_to_string(template: "map/_leaflet", 
                                  layout:   false, 
                                  locals:   {
                                    lat:   lat,
                                    lon:   lon,
                                    items: items
                                  }
               )
      output
    end
  end

  # in our interface, "users" are known as "people" because it's more human
  def self.people_grid(body, _page = 1)
    body.gsub(/[^\>`](\<p\>)?\[people\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2).parameterize
      users = User.where(status: 1)
                  .includes(:user_tags)
                  .where('user_tags.value = ?', tagname)
      output = ''
      output += '<p>' if Regexp.last_match(1) == '<p>'
      a = ActionController::Base.new()
      output += a.render_to_string(template: "grids/_people", 
                                   layout:   false, 
                                   locals:   {
                                     tagname: tagname,
                                     randomSeed: rand(1000).to_s,
                                     className: 'people-grid-' + tagname,
                                     users: users
                                   })
      output
    end
  end

end
