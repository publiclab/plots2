module ApplicationHelper

  # returns true if user is logged in and has any of the roles given, as ['admin','moderator']
  def logged_in_as(roles)
    if current_user
      has_valid_role = false
      roles.each do |role|
        has_valid_role = true if current_user.role == role
      end
      return has_valid_role
    else
      return false
    end
  end

  def feature(title)
    features = Node.where(type: 'feature', title: title)
    if features.length > 0
      return features.last.body.html_safe
    else
      ""
    end
  end

  def locale_name_pairs
    I18n.available_locales.map do |locale|
      [I18n.t('language', locale: locale), locale]
    end
  end

  def insert_extras(body)
    body = body.gsub(/\<p\>\[notes\:(.+)\]/) do |tagname|
      randomSeed = rand(1000).to_s
      className = 'notes-grid-' + $1.parameterize
      output  = '<p><table class="table inline-grid notes-grid ' + className + ' ' + className + '-' + randomSeed + '">'
      output += '  <tr>'
      output += '    <th><a data-type="title">Title</a></th>'
      output += '    <th><a data-type="author">Author</a></th>'
      output += '    <th><a data-type="updated">Updated</a></th>'
      output += '    <th><a data-type="likes">Likes</a></th>'
      output += '  </tr>'
      nodes = Node.where(status: 1, type: 'note')
                        .includes(:drupal_node_revision, :tag)
                        .where('term_data.name = ?', $1)
                        .page(params[:page])
                        .order("node_revisions.timestamp DESC")
      nodes.each do |node1|
        output += '<tr>'
        output += '  <td class="title"><a href="' + node1.path + '">' + node1.title + '</a></td>'
        output += '  <td class="author"><a href="/profile/' + node1.author.username + '">@' + node1.author.username + '</a></td>'
        output += '  <td class="updated" data-timestamp="' + node1.latest.timestamp.to_s + '">' + distance_of_time_in_words(Time.at(node1.latest.updated_at), Time.current, false, :scope => :'datetime.time_ago_in_words') + '</td>'
        output += '  <td class="likes">' + number_with_delimiter(node1.cached_likes) + '</td>'
        output += '</tr>'
      end
      output += '</table>'
      output += '<script>(function(){ setupGridSorters(".' + className + '-' + randomSeed + '"); })()</script>'
      output
    end

    body = body.gsub(/\<p\>\[activities\:(.+)\]/) do |tagname|
      randomSeed = rand(1000).to_s
      className = 'activity-grid-' + $1.parameterize
      output  = '<p><table class="table inline-grid activity-grid ' + className + ' ' + className + '-' + randomSeed + '">'
      output += '  <tr>'
      output += '    <th><a data-type="title">Purpose</a></th>'
      output += '    <th><a data-type="category">Category</a></th>'
      output += '    <th><a data-type="status">Status</a></th>'
      output += '    <th><a data-type="author">Author</a></th>'
      output += '    <th><a data-type="time">Time</a></th>'
      output += '    <th><a data-type="difficulty">Difficulty</a></th>'
      output += '    <th><a data-type="replications">Replications</a></th>'
      output += '  </tr>'
      nodes = Node.activities($1)
                        .order("node.cached_likes DESC")
      nodes.each do |node1|
        output += '<tr>'
        output += '  <td class="title"><a href="' + node1.path + '">' + node1.title + '</a></td>'
        output += '  <td class="category">' + (node1.has_power_tag('category') ? node1.power_tag('category') : '-') + '</td>'
        output += '  <td class="status">' + (node1.has_power_tag('status') ? node1.power_tag('status') : '-') + '</td>'
        output += '  <td class="author"><a href="/profile/' + node1.author.username + '">@' + node1.author.username + '</a></td>'
        output += '  <td class="time">' + (node1.has_power_tag('time') ? node1.power_tag('time') : '-') + '</td>'
        output += '  <td class="difficulty">' + (node1.has_power_tag('difficulty') ? node1.power_tag('difficulty') : '-') + '</td>'
        output += '  <td class="replications">' + node1.response_count('replication').to_s + ' replications: <a href="' + node1.path + '#replications">Try it &raquo;</a></td>'
        output += '</tr>'
      end
      output += '</table>'
      output += "<p><a href='/post?tags=activity:#{$1},#{$1},seeks:replications&title=How%20to%20do%20X' class='btn btn-primary add-activity'>Add an activity</a> <a href='/post?tags=#{$1},question:#{$1},request:activity&template=question&title=How%20do%20I...&redirect=question' class='btn btn-primary request-activity'>Request an activity guide</a></p>"
      output += '<p><i>Activities should include a materials list, costs and a step-by-step guide to construction with photos. Learn what <a href="https://publiclab.org/notes/warren/09-17-2016/what-makes-a-good-activity">makes a good activity here</a>.</i></p>'
      output += '<script>(function(){ setupGridSorters(".' + className + '-' + randomSeed + '"); })()</script>'
      output
    end

    body = body.gsub(/\<p\>\[upgrades\:(.+)\]/) do |tagname|
      randomSeed = rand(1000).to_s
      className = 'upgrades-grid-' + $1.parameterize
      output  = '<p><table class="table inline-grid upgrades-grid ' + className + ' ' + className + '-' + randomSeed + '">'
      output += '  <tr>'
      output += '    <th><a data-type="title">Title</a></th>'
      output += '    <th><a data-type="status">Status</a></th>'
      output += '    <th><a data-type="author">Author</a></th>'
      output += '    <th><a data-type="time">Time</a></th>'
      output += '    <th><a data-type="difficulty">Difficulty</a></th>'
      output += '    <th><a data-type="builds">Builds</a></th>'
      output += '  </tr>'
      nodes = Node.upgrades($1)
                        .order("node.cached_likes DESC")
      nodes.each do |node1|
        output += '<tr>'
        output += '  <td class="title"><a href="' + node1.path + '">' + node1.title + '</a></td>'
        output += '  <td class="status">' + (node1.has_power_tag('status') ? node1.power_tag('status') : '-') + '</td>'
        output += '  <td class="author"><a href="/profile/' + node1.author.username + '">@' + node1.author.username + '</a></td>'
        output += '  <td class="time">' + (node1.has_power_tag('time') ? node1.power_tag('time') : '-') + '</td>'
        output += '  <td class="difficulty">' + (node1.has_power_tag('difficulty') ? node1.power_tag('difficulty') : '-') + '</td>'
        output += '  <td class="builds">' + node1.response_count('build').to_s + ' builds: <a href="' + node1.path + '#builds">Try it &raquo;</a></td>'
        output += '</tr>'
      end
      output += '</table>'
      output += '<script>(function(){ setupGridSorters(".' + className + '-' + randomSeed + '"); })()</script>'
      output
    end

    body
  end

  def render_map(lat, lon, items)
    render partial: 'map/leaflet', locals: { lat: lat, lon: lon, items: items }
  end


end
