class DrupalNodeAccess < ActiveRecord::Base
  attr_accessible :nid, :gid, :realm, :grant_view, :grant_update, :grant_delete
  
  self.table_name = 'node_access'
  self.primary_key = :nid

  belongs_to :drupal_node, :foreign_key => 'nid', :dependent => :destroy

end
