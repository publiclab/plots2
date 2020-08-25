module ApplicationHelper
  include Pagy::Frontend

  # returns true if user is logged in and has any of the roles given, as ['admin','moderator']
  def logged_in_as(roles)
    return false unless current_user

    roles.include? current_user.role
  end

  def emojify(content)
    if content.present?
      content.to_str.gsub(/:([\w+-]+):(?![^\[]*\])/) do |match|
        if emoji = Emoji.find_by_alias(Regexp.last_match(1))
          emoji.raw || %(<img class="emoji" alt="#{Regexp.last_match(1)}" src="#{image_path("emoji/#{emoji.image_filename}")}" style="vertical-align:middle" width="20" height="20" />)
        else
          match
        end
      end
    end
  end

  def emoji_names_list
    emojis = []
    image_map = {}
    Emoji.all.each do |e|
      next unless e.raw

      val = ":#{e.name}:"
      emojis << { value: val, text: e.name }
      image_map[e.name] = e.raw
    end
    { emojis: emojis, image_map: image_map }
  end

  def emoji_info
    emoji_names = %w(thumbs-up thumbs-down laugh hooray confused heart)
    prefix = "https://github.githubassets.com/images/icons/emoji/unicode/"
    emoji_image_map = {
      "thumbs-up"   => "#{prefix}1f44d.png",
      "thumbs-down" => "#{prefix}1f44e.png",
      "laugh"       => "#{prefix}1f604.png",
      "hooray"      => "#{prefix}1f389.png",
      "confused"    => "#{prefix}1f615.png",
      "heart"       => "#{prefix}2764.png"
    }
    [emoji_names, emoji_image_map]
  end

  def feature(title)
    features = Node.where(type: 'feature', title: title)
    if !features.empty?
      return features.last.body.to_s.html_safe
    else
      ''
    end
  end

  def feature_node(title)
    features = Node.where(type: 'feature', title: title)
    if !features.empty?
      return features.last
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
    body = NodeShared.notes_thumbnail_grid(body)
    body = NodeShared.nodes_thumbnail_grid(body)
    body = NodeShared.button(body)
    body = NodeShared.nodes_grid(body)
    body = NodeShared.notes_grid(body)
    body = NodeShared.questions_grid(body)
    body = NodeShared.activities_grid(body)
    body = NodeShared.upgrades_grid(body)
    body = NodeShared.notes_map(body)
    body = NodeShared.notes_map_by_tag(body)
    body = NodeShared.people_map(body)
    body = NodeShared.tag_layers_map(body)
    body = NodeShared.layers_map(body)
    body = NodeShared.people_grid(body, @current_user || nil) # <= to allow testing of insert_extras
    body = NodeShared.graph_grid(body)
    body = NodeShared.wikis_grid(body)
    body = NodeShared.simple_data_grapher(body)
    body
  end

  # we should move this to the Node model:
  def render_map(lat, lon, zoom = '')
    render partial: 'map/leaflet', locals: { lat: lat, lon: lon, zoom: zoom, top_map: false }
  end

  def render_top_map(lat, lon, zoom = '')
    render partial: 'map/leaflet', locals: { lat: lat, lon: lon, zoom: zoom, top_map: true }
  end

  # we should move this to the Comment model:
  # replaces inline title suggestion(e.g: {New Title}) with the required link to change the title
  def title_suggestion(comment)
    comment.body.gsub(/\[propose:title\](.*?)\[\/propose\]/) do
      a = ActionController::Base.new
      is_creator = ((defined? current_user) && current_user == Node.find(comment.nid).author) == true
      title = Regexp.last_match(1)
      output = a.render_to_string(template: "notes/_title_suggestion",
                                  layout: false,
                                  locals: {
                                    user: comment.user.name,
                                    nid: comment.nid,
                                    title: title,
                                    is_creator: is_creator
                                  })
      output
    end
  end

  def filtered_comment_body(comment_body)
    if contain_trimmed_body?(comment_body)
      return comment_body.split(Comment::COMMENT_FILTER).first
    end

    comment_body
  end

  def contain_trimmed_body?(comment_body)
    comment_body.include?(Comment::COMMENT_FILTER)
  end

  def trimmed_body(comment_body)
    comment_body.split(Comment::COMMENT_FILTER).second
  end

  def current_page?(page)
    'is-active' if request.path == page
  end

  def translation(key, options = {})
    translated_string = t(key, options)
    options[:fallback] = false
    translated_string2 = t(key, options)

    if current_user&.has_tag('translation-helper') && translated_string2.include?("translation missing") && !translated_string.include?("<")
      raw(%(<span>#{translated_string} <a href="https://www.transifex.com/publiclab/publiclaborg/translate/#de/$?q=text%3A#{translated_string}">
          <i data-toggle='tooltip' data-placement='top' title='Needs translation? Click to help translate this text.' style='position:relative; right:2px; color:#bbb; font-size: 15px;' class='fa fa-globe'></i></a>
       </span>))
    else
      raw(translated_string)
    end
  end
end
