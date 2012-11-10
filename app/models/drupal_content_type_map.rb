class DrupalContentTypeMap < ActiveRecord::Base
  # attr_accessible :title, :body
  self.table_name = 'content_type_map'

  belongs_to :drupal_node, :foreign_key => 'nid'

  def tms
    self.field_tms_url_value
  end

end
