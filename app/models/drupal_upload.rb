class DrupalUpload < ActiveRecord::Base
  attr_accessible :vid, :nid, :fid
  self.table_name = 'upload'
  belongs_to :node, :foreign_key => 'nid', :dependent => :destroy
  belongs_to :drupal_file, :foreign_key => 'fid'

  def node
    self.node
  end

  def file
    self.drupal_file
  end

end
