class DrupalUsers < ActiveRecord::Base
  # attr_accessible :title, :body
  self.table_name = 'users'
  self.primary_key = 'fid'

  has_many :drupal_node, :foreign_key => 'uid'

  def notes
    DrupalNode.find_all_by_uid self.uid
  end

end
