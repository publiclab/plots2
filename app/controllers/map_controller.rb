class MapController < ApplicationController

  def index
    @title = "Maps"
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'map', :status => 1}, :page => params[:page])
    @maps = DrupalNode.find(:all, :order => "nid DESC", :conditions => {:type => 'map', :status => 1})
  end

  def show
    @node = DrupalNode.find_map_by_slug(params[:name]+'/'+params[:date])
    @node.view
    @title = @node.title
    @tags = @node.tags
    @tagnames = @tags.collect(&:name)

    set_sidebar :tags, @tagnames
  end

  def edit
    @node = DrupalNode.find(params[:id],:conditions => {:type => "map"})
    if current_user.uid == @node.uid || current_user.role == "admin" 
      render :template => "map/edit"
    else
      prompt_login "Only admins can edit maps at this time."
    end
  end

  def update
    @node = DrupalNode.find(params[:id],:conditions => {:type => "map"})
    if current_user.uid == @node.uid || current_user.role == "admin" 

      @node.title = params[:title]
      @revision = @node.latest
      @revision.title = params[:title]
      @revision.body = params[:body]

      if params[:tags]
        params[:tags].split(',').each do |tagname|
          @node.add_tag(tagname,current_user)
        end
      end

      # save main image
      if params[:main_image] && params[:main_image] != ""
        img = Image.find params[:main_image]
        unless img.nil?
          img.nid = @node.id
          img.save
        end
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
      #@node.drupal_content_field_map_editor
      #@node.drupal_content_field_mappers.collect(&:field_mappers_value).uniq.join(', ')

      if @node.save && @revision.save && map.save
        flash[:notice] = "Edits saved."
        redirect_to @node.path
      else
        flash[:error] = "Your edit could not be saved."
        render :action => :edit
      end
    else
      prompt_login "Only admins can edit maps at this time."
      prompt_login "Only admins can edit maps at this time."
    end
  end

  def new
  end

  def create
  end

  def tag
    set_sidebar :tags, [params[:id]], {:note_count => 20}

    @tagnames = params[:id].split(',')
    nids = DrupalTag.find_nodes_by_type(params[:id],'map',20).collect(&:nid)
    @notes = DrupalNode.paginate(:conditions => ['nid in (?)', nids], :order => "nid DESC", :page => params[:page])

    @title = @tagnames.join(', ') if @tagnames
    @unpaginated = true
    render :template => 'tag/show'
  end

end
