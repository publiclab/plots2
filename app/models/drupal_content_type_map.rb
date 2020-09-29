class DrupalContentTypeMap < ApplicationRecord
  self.table_name = 'content_type_map'
  self.primary_key = 'vid'

  belongs_to :node, foreign_key: 'nid', dependent: :destroy

  validates :field_zoom_min_value, presence: true

  before_save :truncate_fields

  def truncate_fields
    self.field_publication_date_value = field_publication_date_value.slice(0, 19)
  end

  def tms
    field_tms_url_value
  end

  def min_zoom
    field_zoom_min_value
  end

  def max_zoom
    field_zoom_max_value
  end

  def cartographer_notes
    field_cartographer_notes_value
  end

  def license
    l = "<a href='http://creativecommons.org/publicdomain/zero/1.0/'>Public Domain</a>" if field_license_value == 'publicdomain'
    l = "<a href='http://creativecommons.org/licenses/by/3.0/'>CC-BY</a>" if field_license_value == 'cc-by'
    l = "<a href='http://creativecommons.org/licenses/by-sa/3.0/'>CC-BY-SA</a>" if field_license_value == 'cc-by-sa'
    l
  end

  def notes
    field_notes_value
  end

  def published_on
    field_publication_date_value
  end

  def captured_on
    field_capture_date_value
  end
end
