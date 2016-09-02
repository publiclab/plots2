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
    features = DrupalNode.where(type: 'feature', title: title)
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
      className = 'notes-grid-' + $1.parameterize + '-' + rand(1000).to_s
      output  = '<p><table class="table inline-grid notes-grid ' + className + '">'
      output += '  <tr>'
      output += '    <th><a data-type="title">Title</a></th>'
      output += '    <th><a data-type="author">Author</a></th>'
      output += '    <th><a data-type="updated">Updated</a></th>'
      output += '    <th><a data-type="likes">Likes</a></th>'
      output += '  </tr>'
      nodes = DrupalNode.where(status: 1, type: 'note')
                        .includes(:drupal_node_revision, :drupal_tag)
                        .where('term_data.name = ?', $1)
                        .page(params[:page])
                        .order("node_revisions.timestamp DESC")
      nodes.each do |node|
        output += '<tr>'
        output += '  <td class="title"><a href="' + node.path + '">' + node.title + '</a></td>'
        output += '  <td class="author"><a href="/profile/' + node.author.username + '">@' + node.author.username + '</a></td>'
        output += '  <td class="updated" data-timestamp="' + node.latest.timestamp.to_s + '">' + distance_of_time_in_words(Time.at(node.latest.updated_at), Time.current, false, :scope => :'datetime.time_ago_in_words') + '</td>'
        output += '  <td class="likes">' + number_with_delimiter(node.cached_likes) + '</td>'
        output += '</tr>'
      end
      output += '</table>'
      output += '<script>(function(){ setupGridSorters(".' + className + '"); })()</script>'
      output
    end

    body = body.gsub(/\<p\>\[activities\:(.+)\]/) do |tagname|
      className = 'activity-grid-' + $1.parameterize + '-' + rand(1000).to_s
      output  = '<p><table class="table inline-grid activity-grid ' + className + '">'
      output += '  <tr>'
      output += '    <th><a data-type="title">Purpose</a></th>'
      output += '    <th><a data-type="category">Category</a></th>'
      output += '    <th><a data-type="status">Status</a></th>'
      output += '    <th><a data-type="author">Author</a></th>'
      output += '    <th><a data-type="time">Time</a></th>'
      output += '    <th><a data-type="difficulty">Difficulty</a></th>'
      output += '    <th><a data-type="replications">Replications</a></th>'
      output += '  </tr>'
      nodes = DrupalNode.where(status: 1, type: 'note')
                        .includes(:drupal_node_revision, :drupal_tag)
                        .where('term_data.name LIKE ?', "activity:#{$1}")
                        .page(params[:page])
                        .order("node_revisions.timestamp DESC")
      nodes.each do |node|
        output += '<tr>'
        output += '  <td class="title"><a href="' + node.path + '">' + node.title + '</a></td>'
        output += '  <td class="category">' + (node.has_power_tag('category') ? node.power_tag('category') : '-') + '</td>'
        output += '  <td class="status">' + (node.has_power_tag('status') ? node.power_tag('status') : '-') + '</td>'
        output += '  <td class="author"><a href="/profile/' + node.author.username + '">@' + node.author.username + '</a></td>'
        output += '  <td class="time">' + (node.has_power_tag('time') ? node.power_tag('time') : '-') + '</td>'
        output += '  <td class="difficulty">' + (node.has_power_tag('difficulty') ? node.power_tag('difficulty') : '-') + '</td>'
        output += '  <td class="replications">' + node.response_count('replication').to_s + ' replications</td>'
        output += '</tr>'
      end
      output += '</table>'
      output += '<script>(function(){ setupGridSorters(".' + className + '"); })()</script>'
      output
    end

    body = body.gsub(/\<p\>\[upgrades\:(.+)\]/) do |tagname|
      className = 'upgrades-grid-' + $1.parameterize + '-' + rand(1000).to_s
      output  =  '<p><table class="table inline-grid upgrades-grid ' + className + '">'
      output += '  <tr>'
      output += '    <th><a data-type="title">Title</a></th>'
      output += '    <th><a data-type="status">Status</a></th>'
      output += '    <th><a data-type="author">Author</a></th>'
      output += '    <th><a data-type="time">Time</a></th>'
      output += '    <th><a data-type="difficulty">Difficulty</a></th>'
      output += '    <th><a data-type="builds">Builds</a></th>'
      output += '  </tr>'
      nodes = DrupalNode.where(status: 1, type: 'note')
                        .includes(:drupal_node_revision, :drupal_tag)
                        .where('term_data.name LIKE ?', "upgrade:#{$1}")
                        .page(params[:page])
                        .order("node.cached_likes DESC")
      nodes.each do |node|
        output += '<tr>'
        output += '  <td class="title"><a href="' + node.path + '">' + node.title + '</a></td>'
        output += '  <td class="status">' + (node.has_power_tag('status') ? node.power_tag('status') : '-') + '</td>'
        output += '  <td class="author"><a href="/profile/' + node.author.username + '">@' + node.author.username + '</a></td>'
        output += '  <td class="time">' + (node.has_power_tag('time') ? node.power_tag('time') : '-') + '</td>'
        output += '  <td class="difficulty">' + (node.has_power_tag('difficulty') ? node.power_tag('difficulty') : '-') + '</td>'
        output += '  <td class="builds">' + node.response_count('build').to_s + ' builds</td>'
        output += '</tr>'
      end
      output += '</table>'
      output += '<script>(function(){ setupGridSorters(".' + className + '"); })()</script>'
      output
    end

    body
  end

end
