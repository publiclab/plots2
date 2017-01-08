class DrupalNodeCounter < ActiveRecord::Base
  attr_accessible :totalcount, :nid
  self.table_name = 'node_counter'

  belongs_to :node, :foreign_key => 'nid', :dependent => :destroy

  is_impressionable :counter_cache => true, :column_name => :totalcount, :unique => :ip_address
end
