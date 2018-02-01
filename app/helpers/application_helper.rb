module ApplicationHelper
  # returns true if user is logged in and has any of the roles given, as ['admin','moderator']
  def logged_in_as(roles)
    if current_user
      has_valid_role = false
      roles.each do |role|
        has_valid_role = true if current_user.role == role
      end
      has_valid_role
    else
      false
    end
  end

  def feature(title)
    features = Node.where(type: 'feature', title: title)
    if !features.empty?
      return features.last.body.to_s.html_safe
    else
      ''
    end
  end

  def locale_name_pairs
    I18n.available_locales.map do |locale|
      [I18n.t('language', locale: locale), locale]
    end
  end

  def insert_extras(body)
    body = NodeShared.notes_grid(body)
    body = NodeShared.questions_grid(body)
    body = NodeShared.activities_grid(body)
    body = NodeShared.upgrades_grid(body)
    body = NodeShared.notes_map(body)
    body = NodeShared.notes_map_by_tag(body)
    body = NodeShared.people_map(body)
    body = NodeShared.people_grid(body, @current_user || nil) # <= to allow testing of insert_extras
    body = NodeShared.graph_grid(body)
    body = NodeShared.wikis_grid(body)
    body
  end

  def render_map(lat, lon, items)
    render partial: 'map/leaflet', locals: { lat: lat, lon: lon, items: items }
  end

  # returns the comment body which is to be shown in the comments section
  def render_comment_body(comment)
    raw sanitize RDiscount.new(title_suggestion(comment)).to_html, attributes: %w(class style href data-method src)
  end
  
  # replaces inline title suggestion(e.g: {New Title}) with the required link to change the title
  def title_suggestion(comment)
    comment.body.gsub(/\[propose:title\](.*?)\[\/propose\]/) do ||
      a = ActionController::Base.new
      is_creator = current_user.drupal_user == Node.find(comment.nid).author
      title = Regexp.last_match(1)
      output = a.render_to_string(template: "notes/_title_suggestion",
                                  layout:   false,
                                  locals:   {
                                    user: comment.drupal_user.name,
                                    nid: comment.nid,
                                    title: title,
                                    is_creator: is_creator
                                  })
      output
    end
  end
end
