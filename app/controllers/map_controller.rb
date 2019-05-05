class MapController < ApplicationController
  def index
    @title = 'Maps'
    @nodes = Node.paginate(page: params[:page], per_page: 32)
      .order('nid DESC')
      .where(type: 'map', status: 1)

    @map_lat = nil
    @map_lon = nil
    if current_user&.has_power_tag("lat") && current_user&.has_power_tag("lon")
      @map_lat = current_user.get_value_of_power_tag("lat").to_f
      @map_lon = current_user.get_value_of_power_tag("lon").to_f
    end
    # I'm not sure if this is actually eager loading the tags...
    @maps = Node.joins(:tag)
      .where('type = "map" AND status = 1 AND (term_data.name LIKE ? OR term_data.name LIKE ?)', 'lat:%', 'lon:%')
      .distinct

    # This is supposed to eager load the url_aliases, and seems to run, but doesn't actually eager load them...?
    # @maps = Node.select("node.*,url_alias.dst AS dst").joins(:tag).where('type = "map" AND status = 1 AND (term_data.name LIKE ? OR term_data.name LIKE ?)', 'lat:%', 'lon:%').joins("INNER JOIN url_alias ON url_alias.src = CONCAT('node/',node.nid)")
  end

  def show
    @node = Node.find_map(params[:name], params[:date])

    # redirect_old_urls

    impressionist(@node)
    @title = @node.title
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)

    set_sidebar :tags, @tagnames
  end

  def edit
    @node = Node.find_by(id: params[:id])
    if current_user.uid == @node.uid || logged_in_as(['admin'])
      render template: 'map/edit'
    else
      prompt_login 'Only admins can edit maps at this time.'
    end
  end

  def delete
    @node = Node.find_by(id: params[:id])
    if current_user.uid == @node.uid || logged_in_as(['admin'])
      @node.delete
      flash[:notice] = 'Content deleted.'
      redirect_to '/archive'
    else
      prompt_login 'Only admins can edit maps at this time.'
    end
  end

  def update
    @node = Node.find(params[:id])
    if current_user.uid == @node.uid || logged_in_as(['admin'])

      @node.title = params[:title]
      @revision = @node.latest
      @revision.title = params[:title]
      @revision.body = params[:body]

      params[:tags]&.split(',')&.each do |tagname|
        @node.add_tag(tagname, current_user)
      end

      # save main image
      if params[:main_image] && params[:main_image] != ''
        img = Image.find params[:main_image]
        unless img.nil?
          img.nid = @node.id
          img.save
        end
      end

      %i(lat lon).each do |coordinate|
        if coordinate_name = coordinate.to_s + ':' + @node.power_tag(coordinate.to_s)
          existing_coordinate_node_tag = NodeTag.where(nid: @node.id).joins(:tag).where("name = ?", coordinate_name).first
          existing_coordinate_node_tag.delete
        end
        @node.add_tag(coordinate.to_s + ':' + params[coordinate], current_user)
      end

      map = @node.map
      map.field_publication_date_value    = params[:map][:field_publication_date_value]
      map.field_capture_date_value        = params[:map][:field_capture_date_value]
      map.field_geotiff_url_value         = params[:map][:field_geotiff_url_value]
      map.field_google_maps_url_value     = params[:map][:field_google_maps_url_value]
      map.field_openlayers_url_value      = params[:map][:field_openlayers_url_value]
      map.field_tms_url_value             = params[:map][:field_tms_url_value]
      map.field_jpg_url_value             = params[:map][:field_jpg_url_value]
      map.field_license_value             = params[:map][:field_license_value]
      map.field_raw_images_value          = params[:map][:field_raw_images_value]
      map.field_cartographer_notes_value  = params[:map][:field_cartographer_notes_value]
      map.field_notes_value               = params[:map][:field_notes_value]
      map.field_mbtiles_url_value         = params[:map][:field_mbtiles_url_value]
      map.field_zoom_min_value            = params[:map][:field_zoom_min_value]
      map.field_ground_resolution_value   = params[:map][:field_ground_resolution_value]
      map.field_geotiff_filesize_value    = params[:map][:field_geotiff_filesize_value]
      map.field_jpg_filesize_value        = params[:map][:field_jpg_filesize_value]
      map.field_raw_images_filesize_value = params[:map][:field_raw_images_filesize_value]
      map.field_tms_tile_type_value       = params[:map][:field_tms_tile_type_value]
      map.field_zoom_max_value            = params[:map][:field_zoom_max_value]

      # need to create/delete these. Maybe best just make a new field, no need to store individual records
      # @node.drupal_content_field_map_editor
      # @node.drupal_content_field_mappers.collect(&:field_mappers_value).uniq.join(', ')
      # combined record as string:
      map.authorship                      = params[:map][:authorship]

      if @node.save && @revision.save && map.save
        flash[:notice] = 'Edits saved.'
        redirect_to @node.path
      else
        flash[:error] = 'Your edit could not be saved.'
        render action: :edit
      end
    else
      prompt_login 'Only admins can edit maps at this time.'
    end
  end

  def new
    if logged_in_as(['admin'])
      @node = Node.new(type: 'map')
      render template: 'map/edit'
    else
      prompt_login 'Only admins can publish maps at this time.'
    end
  end

  # must require min_zoom and lat/lon location, and TMS URL
  # solving this by min_zoom default here, but need better solution
  def create
    if logged_in_as(['admin'])
      saved, @node, @revision = Node.new_node(uid: current_user.uid,
                                              title: params[:title],
                                              body: params[:body],
                                              type: 'map',
                                              main_image: params[:main_image])

      if saved
        params[:tags]&.split(',')&.each do |tagname|
          @node.add_tag(tagname, current_user)
        end

        # save main image
        if params[:main_image] && params[:main_image] != ''
          img = Image.find params[:main_image]
          unless img.nil?
            img.nid = @node.id
            img.save
          end
        end

        @node.add_tag('lat:' + params[:lat], current_user)
        @node.add_tag('lon:' + params[:lon], current_user)

        map = DrupalContentTypeMap.new
        map.nid = @node.nid
        map.vid = @node.nid

        map.field_publication_date_value    = params[:map][:field_publication_date_value]
        map.field_capture_date_value        = params[:map][:field_capture_date_value]
        map.field_geotiff_url_value         = params[:map][:field_geotiff_url_value]
        map.field_google_maps_url_value     = params[:map][:field_google_maps_url_value]
        map.field_openlayers_url_value      = params[:map][:field_openlayers_url_value]
        map.field_tms_url_value             = params[:map][:field_tms_url_value]
        map.field_jpg_url_value             = params[:map][:field_jpg_url_value]
        map.field_license_value             = params[:map][:field_license_value]
        map.field_raw_images_value          = params[:map][:field_raw_images_value]
        map.field_cartographer_notes_value  = params[:map][:field_cartographer_notes_value]
        map.field_notes_value               = params[:map][:field_notes_value]
        map.field_mbtiles_url_value         = params[:map][:field_mbtiles_url_value]
        map.field_zoom_min_value            = params[:map][:field_zoom_min_value]
        map.field_zoom_min_value ||= 17
        map.field_ground_resolution_value   = params[:map][:field_ground_resolution_value]
        map.field_geotiff_filesize_value    = params[:map][:field_geotiff_filesize_value]
        map.field_jpg_filesize_value        = params[:map][:field_jpg_filesize_value]
        map.field_raw_images_filesize_value = params[:map][:field_raw_images_filesize_value]
        map.field_tms_tile_type_value       = params[:map][:field_tms_tile_type_value]
        map.field_zoom_max_value            = params[:map][:field_zoom_max_value]

        # need to create/delete these. Maybe best just make a new field, no need to store individual records
        # @node.drupal_content_field_map_editor
        # @node.drupal_content_field_mappers.collect(&:field_mappers_value).uniq.join(', ')
        map.authorship                      = params[:map][:authorship]

        ActiveRecord::Base.transaction do # in case only part of this completes
          if @node.save && @revision.save && map.save
            flash[:notice] = 'Edits saved.'
            redirect_to @node.path
          else
            flash[:error] = 'Your edit could not be saved.'
            render action: :edit
          end
        end
      else
        flash[:error] = 'Your edit could not be saved.'
        render template: 'map/edit'
      end
    else
      prompt_login 'Only admins can publish maps at this time.'
    end
  end

  def tag
    set_sidebar :tags, [params[:id]], note_count: 20

    @tagnames = params[:id].split(',')
    nids = Tag.find_nodes_by_type(params[:id], 'map', 20).collect(&:nid)
    @notes = Node.paginate(page: params[:page])
      .where('nid in (?)', nids)
      .order('nid DESC')

    @title = @tagnames.join(', ') if @tagnames
    @unpaginated = true
    render template: 'tag/show'
  end
end
