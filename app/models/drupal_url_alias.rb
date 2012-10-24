class DrupalUrlAlias < ActiveRecord::Base
  # attr_accessible :title, :body
  self.table_name = 'url_alias'
  self.primary_key = 'pid'

  def node
    DrupalNode.find self.src.split('/')[1]
  end

end
