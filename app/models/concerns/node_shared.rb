module NodeShared
  extend ActiveSupport::Concern

  def likes
    self.cached_likes
  end

  def liked_by(uid)
    self.likers.collect(&:uid).include?(uid)
  end

  # rubular regex: http://rubular.com/r/hBEThNL4qd
  def self.notes_grid(body, page = 1)
    body.gsub(/[^\>`](\<p\>)?\[notes\:(\S+)\]/) do |tagname|
      randomSeed = rand(1000).to_s
      className = 'notes-grid-' + $2.parameterize
      output = ''
      output += '<table class="table inline-grid notes-grid ' + className + ' ' + className + '-' + randomSeed + '">'
      output += '  <tr>'
      output += '    <th><a data-type="title">Title</a></th>'
      output += '    <th><a data-type="author">Author</a></th>'
      output += '    <th><a data-type="updated">Updated</a></th>'
      output += '    <th><a data-type="likes">Likes</a></th>'
      output += '  </tr>'
      nodes = DrupalNode.where(status: 1, type: 'note')
                        .includes(:drupal_node_revision, :tag)
                        .where('term_data.name = ?', $1)
                        .order("node_revisions.timestamp DESC")
      nodes.each do |node|
        output += '<tr>'
        output += '  <td class="title"><a href="' + node.path + '">' + node.title + '</a></td>'
        output += '  <td class="author"><a href="/profile/' + node.author.username + '">@' + node.author.username + '</a></td>'
        output += '  <td class="updated" data-timestamp="' + node.latest.timestamp.to_s + '">' + distance_of_time_in_words(Time.at(node.latest.updated_at), Time.current, false, :scope => :'datetime.time_ago_in_words') + '</td>'
        output += '  <td class="likes">' + node.cached_likes.to_s + '</td>'
        output += '</tr>'
      end
      output += '</table>'
      output += '<script>(function(){ setupGridSorters(".' + className + '-' + randomSeed + '"); })()</script>'
      output
    end
  end

  def self.activities_grid(body)
    body.gsub(/[^\>`](\<p\>)?\[activities\:(\S+)\]/) do |tagname|
      randomSeed = rand(1000).to_s
      className = 'activity-grid-' + $2.parameterize
      output = ''
      output += '<p>' if tagname[0..2] == '<p>'
      output += '<table class="table inline-grid activity-grid ' + className + ' ' + className + '-' + randomSeed + '">'
      output += '  <tr>'
      output += '    <th><a data-type="title">Purpose</a></th>'
      output += '    <th><a data-type="category">Category</a></th>'
      output += '    <th><a data-type="status">Status</a></th>'
      output += '    <th><a data-type="author">Author</a></th>'
      output += '    <th><a data-type="time">Time</a></th>'
      output += '    <th><a data-type="difficulty">Difficulty</a></th>'
      output += '    <th><a data-type="replications">Replications</a></th>'
      output += '  </tr>'
      nodes = DrupalNode.activities($1)
                        .order("node.cached_likes DESC")
      nodes.each do |node|
        output += '<tr>'
        output += '  <td class="title"><a href="' + node.path + '">' + node.title + '</a></td>'
        output += '  <td class="category">' + (node.has_power_tag('category') ? node.power_tag('category') : '-') + '</td>'
        output += '  <td class="status">' + (node.has_power_tag('status') ? node.power_tag('status') : '-') + '</td>'
        output += '  <td class="author"><a href="/profile/' + node.author.username + '">@' + node.author.username + '</a></td>'
        output += '  <td class="time">' + (node.has_power_tag('time') ? node.power_tag('time') : '-') + '</td>'
        output += '  <td class="difficulty">' + (node.has_power_tag('difficulty') ? node.power_tag('difficulty') : '-') + '</td>'
        output += '  <td class="replications">' + node.response_count('replication').to_s + ' replications: <a href="' + node.path + '#replications">Try it &raquo;</a></td>'
        output += '</tr>'
      end
      output += '</table>'
      output += "<p><a href='/post?tags=activity:#{$1},#{$1},seeks:replications&title=How%20to%20do%20X' class='btn btn-primary add-activity'>Add an activity</a> <a href='/post?tags=#{$1},question:#{$1},request:activity&template=question&title=How%20do%20I...&redirect=question' class='btn btn-primary request-activity'>Request an activity guide</a></p>"
      output += '<p><i>Activities should include a materials list, costs and a step-by-step guide to construction with photos. Learn what <a href="https://publiclab.org/notes/warren/09-17-2016/what-makes-a-good-activity">makes a good activity here</a>.</i></p>'
      output += '<script>(function(){ setupGridSorters(".' + className + '-' + randomSeed + '"); })()</script>'
      output
    end
  end

  def self.upgrades_grid(body)
    body.gsub(/[^\>`](\<p\>)?\[upgrades\:(\S+)\]/) do |tagname|
      randomSeed = rand(1000).to_s
      className = 'upgrades-grid-' + $2.parameterize
      output = ''
      output += '<p>' if tagname[0..2] == '<p>'
      output += '<table class="table inline-grid upgrades-grid ' + className + ' ' + className + '-' + randomSeed + '">'
      output += '  <tr>'
      output += '    <th><a data-type="title">Title</a></th>'
      output += '    <th><a data-type="status">Status</a></th>'
      output += '    <th><a data-type="author">Author</a></th>'
      output += '    <th><a data-type="time">Time</a></th>'
      output += '    <th><a data-type="difficulty">Difficulty</a></th>'
      output += '    <th><a data-type="builds">Builds</a></th>'
      output += '  </tr>'
      nodes = DrupalNode.upgrades($1)
                        .order("node.cached_likes DESC")
      nodes.each do |node|
        output += '<tr>'
        output += '  <td class="title"><a href="' + node.path + '">' + node.title + '</a></td>'
        output += '  <td class="status">' + (node.has_power_tag('status') ? node.power_tag('status') : '-') + '</td>'
        output += '  <td class="author"><a href="/profile/' + node.author.username + '">@' + node.author.username + '</a></td>'
        output += '  <td class="time">' + (node.has_power_tag('time') ? node.power_tag('time') : '-') + '</td>'
        output += '  <td class="difficulty">' + (node.has_power_tag('difficulty') ? node.power_tag('difficulty') : '-') + '</td>'
        output += '  <td class="builds">' + node.response_count('build').to_s + ' builds: <a href="' + node.path + '#builds">Try it &raquo;</a></td>'
        output += '</tr>'
      end
      output += '</table>'
      output += '<script>(function(){ setupGridSorters(".' + className + '-' + randomSeed + '"); })()</script>'
      output
    end
  end

end
