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
                  .includes(:drupal_node_revision, :tag)
                  .where('term_data.name = ?', Regexp.last_match(2))
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
                                   }
                  )
      output
    end
  end

  # rubular regex: http://rubular.com/r/hBEThNL4qd
  def self.questions_grid(body, _page = 1)
    body.gsub(/[^\>`](\<p\>)?\[questions\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2).parameterize
      nodes = Node.where(status: 1, type: 'note')
                  .includes(:drupal_node_revision, :tag)
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
                                   }
                  )
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
                                   }
                  )
      output
    end
  end

  def self.upgrades_grid(body)
    body.gsub(/[^\>`](\<p\>)?\[upgrades\:(\S+)\]/) do |_tagname|
      tagname = Regexp.last_match(2).parameterize
      nodes = Node.upgrades(Regexp.last_match(2))
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
                                   }
                  )
      output
    end
  end
end
