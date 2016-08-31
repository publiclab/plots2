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
      output  = '<p><table class="table inline-grid notes-grid notes-grid-' + $1 + '">'
      output += '  <tr>'
      output += '    <th>Title</th>'
      output += '    <th>Author</th>'
      output += '    <th>Updated</th>'
      output += '    <th>Likes</th>'
      output += '  </tr>'
      nodes = DrupalNode.where(status: 1, type: 'note')
                        .includes(:drupal_node_revision, :drupal_tag)
                        .where('term_data.name = ?', $1)
                        .page(params[:page])
                        .order("node_revisions.timestamp DESC")
      nodes.each do |node|
        output += '    <tr>'
        output += '      <td><a href="' + node.path + '">' + node.title + '</a></td>'
        output += '      <td><a href="/profile/' + node.author.username + '">@' + node.author.username + '</a></td>'
        output += '      <td>' + distance_of_time_in_words(Time.at(node.updated_at), Time.current, false, :scope => :'datetime.time_ago_in_words') + '</td>'
        output += '      <td>' + number_with_delimiter(node.cached_likes) + '</td>'
        output += '    </tr>'
      end
      output += '</table>'
      output
    end
    body = body.gsub(/\<p\>\[activities\:(.+)\]/) do |tagname|
      output  = '<p><table class="table inline-grid activity-grid activity-grid-' + $1 + '">'
      output += '  <tr>'
      output += '    <th>Purpose</th>'
      output += '    <th>Category</th>'
      output += '    <th>Status</th>'
      output += '    <th>Author</th>'
      output += '    <th>Time</th>'
      output += '    <th>Difficulty</th>'
      output += '    <th>Replications</th>'
      output += '  </tr>'
      nodes = DrupalNode.where(status: 1, type: 'note')
                        .includes(:drupal_node_revision, :drupal_tag)
                        .where('term_data.name LIKE ?', "activity:#{$1}")
                        .page(params[:page])
                        .order("node_revisions.timestamp DESC")
      nodes.each do |node|
        output += '    <tr>'
        output += '      <td><a href="' + node.path + '">' + node.title + '</a></td>'
        output += '      <td>' + (node.has_power_tag('category') ? node.power_tag('category') : '-') + '</td>'
        output += '      <td>' + (node.has_power_tag('status') ? node.power_tag('status') : '-') + '</td>'
        output += '      <td><a href="/profile/' + node.author.username + '">@' + node.author.username + '</a></td>'
        output += '      <td>' + (node.has_power_tag('time') ? node.power_tag('time') : '-') + '</td>'
        output += '      <td>' + (node.has_power_tag('difficulty') ? node.power_tag('difficulty') : '-') + '</td>'
        output += '      <td>' + node.response_count('replication').to_s + ' replications</td>'
        output += '    </tr>'
      end
      output += '</table>'
      output
    end
    body = body.gsub(/\<p\>\[upgrades\:(.+)\]/) do |tagname|
      output  =  '<p><table class="table inline-grid upgrades-grid upgrades-grid-' + $1 + '">'
      output += '  <tr>'
      output += '    <th>Title</th>'
      output += '    <th>Status</th>'
      output += '    <th>Author</th>'
      output += '    <th>Time</th>'
      output += '    <th>Difficulty</th>'
      output += '    <th>Builds</th>'
      output += '  </tr>'
      nodes = DrupalNode.where(status: 1, type: 'note')
                        .includes(:drupal_node_revision, :drupal_tag)
                        .where('term_data.name LIKE ?', "upgrade:#{$1}")
                        .page(params[:page])
                        .order("node.cached_likes DESC")
      nodes.each do |node|
        output += '    <tr>'
        output += '      <td><a href="' + node.path + '">' + node.title + '</a></td>'
        output += '      <td>' + (node.has_power_tag('status') ? node.power_tag('status') : '-') + '</td>'
        output += '      <td><a href="/profile/' + node.author.username + '">@' + node.author.username + '</a></td>'
        output += '      <td>' + (node.has_power_tag('time') ? node.power_tag('time') : '-') + '</td>'
        output += '      <td>' + (node.has_power_tag('difficulty') ? node.power_tag('difficulty') : '-') + '</td>'
        output += '      <td>' + node.response_count('build').to_s + ' builds</td>'
        output += '    </tr>'
      end
      output += '</table>'
      output
    end
    body
  end

end
