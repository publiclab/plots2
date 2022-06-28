class ConvertMapToNoteNodes < ActiveRecord::Migration[5.2]
  def change
    Node.where(type: 'map').each do |node|
      revision = node.latest
      iframe_link = "<iframe style='width:100%;border:none;background:#ddd;margin-bottom:8px;' height='375' src='https://publiclab.github.io/plots-leaflet-viewer/?tms=#{node.map&.tms}&lon=#{node.lon}&lat=#{node.lat}&zoom=#{node.map&.min_zoom+1}'></iframe>"
      conversion_buttons =
        "<div class='btn-toolbar'>"\
          "<div class='btn-group'>"\
            "<a class='btn btn-sm btn-danger' rel='tooltip' title='View the map in a full-screen web viewer' href='https://publiclab.github.io/plots-leaflet-viewer/?tms=#{node.map&.tms}&lon=#{node.lon}&lat=#{node.lat}&zoom=17'>Web viewer</a>"\
            "<a class='btn btn-sm btn-success' rel='tooltip' title='' href='#{node.map&.field_jpg_url_value}'>JPG (#{node.map&.field_jpg_filesize_value.to_i} MB)</a>"\
            "<a class='btn btn-sm btn-info' rel='tooltip' title='' href='#{node.map&.field_geotiff_url_value}'>GeoTiff (#{node.map&.field_geotiff_filesize_value.to_i} MB)</a>"\
            "<a class='btn btn-sm btn-warning' rel='tooltip' title='Tiled Map Service (for developers)' href='#{node.map&.field_tms_url_value}'>TMS</a>"\
          "</div>"\
        "</div>"

      map_details =
      "<div class='map-details'>"\
        "<small>"

      if node.map&.authorship
        map_details += "<p><b>By</b> #{node.map.authorship}</p>"
      else
        map_details +=
          "<p><b>Mapped by</b> #{node.drupal_content_field_mappers.collect(&:field_mappers_value).uniq.join(', ') }</p>"\
          "<p><b>Cartographer:</b> #{node.drupal_content_field_map_editor.collect(&:field_map_editor_value).uniq.join(', ') }</p>"\
          "<p><b>Published by</b> <a href='/profile/#{node.author.name}'>#{node.author.name}</a></p>"
      end
      map_details +=
        "<p><a href='https://maps.google.com/maps?t=h&ll=#{node.lat},#{node.lon}'>#{node.lat} N, #{node.lon} E</a></p>"\
        "<p>#{node.views} views</p>"

      map_details += "<p><b>Ground resolution: </b>#{node.map&.field_ground_resolution_value} cm/px</p>" if node.map&.field_ground_resolution_value

      map_details +=
            "<p><b>Capture date:</b> #{node.map&.captured_on.to_s}</p>"\
            "<p><b>Publication date:</b> #{node.map&.published_on.to_s}</p>"\
            "<p><b>License:</b> #{node.map&.license.html_safe}</p>"\
          "</small>"\
        "</div><hr />"\
        "<style>.map-details p { margin:4px 0; }</style>"

      notes = "<hr \>"

      unless node.map&.notes.nil?
        notes =
        "<h3>Notes</h3>"\
        "<p>#{node.map&.notes.html_safe}</p>"\
        "<hr />"
      end

      cartographer_notes = ""

      unless node.map&.cartographer_notes.nil?
        cartographer_notes =
        "<h3>Cartographer notes</h3>"\
        "<p>#{node.map&.cartographer_notes.html_safe}</p>"\
        "<hr />"
      end

      old_body = revision.body

      revision.body = iframe_link
      revision.body += conversion_buttons
      revision.body += map_details
      revision.body += old_body
      revision.body += notes
      revision.body += cartographer_notes

      node.type = 'note'
      new_path = node.generate_path
      node.path = new_path
      revision.save
      node.save
    end
  end
end
