# string  "field_publication_date_value",    
# string  "field_capture_date_value",        
# text    "field_geotiff_url_value",         
# text    "field_google_maps_url_value",     
# text    "field_openlayers_url_value",      
# text    "field_tms_url_value",             
# text    "field_jpg_url_value",             
# text    "field_license_value",             
# text    "field_raw_images_value",          
# text    "field_cartographer_notes_value",  
# integer "field_cartographer_notes_format"
# text    "field_notes_value",               
# integer "field_notes_format"
# text    "field_mbtiles_url_value",         
# integer "field_zoom_min_value"
# decimal "field_ground_resolution_value",   
# decimal "field_geotiff_filesize_value",    
# decimal "field_jpg_filesize_value",        
# decimal "field_raw_images_filesize_value", 
# text    "field_tms_tile_type_value",      
# integer "field_zoom_max_value"

class DrupalContentTypeMap < ActiveRecord::Base
  self.table_name = 'content_type_map'

  belongs_to :drupal_node, :foreign_key => 'nid', :dependent => :destroy

  acts_as_mappable :default_units => :miles,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :lat,
                   :lng_column_name => :lng

  def tms
    self.field_tms_url_value
  end

  def min_zoom
    self.field_zoom_min_value
  end

  def max_zoom
    self.field_zoom_max_value
  end

  def cartographer_notes
    self.field_cartographer_notes_value
  end

  def license
    l = "<a href='http://creativecommons.org/publicdomain/zero/1.0/'>Public Domain</a>" if self.field_license_value == "publicdomain"
    l = "<a href='http://creativecommons.org/licenses/by/3.0/'>CC-BY</a>" if self.field_license_value == "cc-by"
    l = "<a href='http://creativecommons.org/licenses/by-sa/3.0/'>CC-BY-SA</a>" if self.field_license_value == "cc-by-sa"
    l
  end

  def notes
    self.field_notes_value
  end

  def published_on
    self.field_publication_date_value
  end

  def captured_on
    self.field_capture_date_value
  end

end
