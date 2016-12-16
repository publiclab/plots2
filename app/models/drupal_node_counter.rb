class DrupalNodeCounter < ActiveRecord::Base
  attr_accessible :totalcount, :nid
  self.table_name = 'node_counter'

  belongs_to :node, :foreign_key => 'nid', :dependent => :destroy

end
