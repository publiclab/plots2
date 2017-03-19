class DrupalContentTypeMap < ActiveRecord::Base
  self.table_name = 'content_type_map'
  self.primary_key = 'vid'

  belongs_to :node, :foreign_key => 'nid', :dependent => :destroy

  validates :field_zoom_min_value, :presence => :true

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
