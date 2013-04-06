class DrupalContentTypeMap < ActiveRecord::Base
  self.table_name = 'content_type_map'

  belongs_to :drupal_node, :foreign_key => 'nid', :dependent => :destroy

  def tms
    self.field_tms_url_value
  end

end
