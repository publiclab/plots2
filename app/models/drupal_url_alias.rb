class DrupalUrlAlias < ActiveRecord::Base
  attr_accessible :dst, :src
  self.table_name = 'url_alias'
  self.primary_key = 'pid'

  def node
    DrupalNode.find self.src.split('/')[1]
  end

end
