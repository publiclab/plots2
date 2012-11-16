class DrupalFile < ActiveRecord::Base
  # attr_accessible :title, :body
  set_table_name :files
  belongs_to :drupal_node, :foreign_key => 'nid'
  self.primary_key = 'fid'

  def path(size)
    size = size || :default
    if size == :thumb
      return 'http://publiclaboratory.org/sites/default/files/imagecache/thumb/'+self.filename
    elsif size == :default
      return 'http://publiclaboratory.org/sites/default/files/imagecache/default/'+self.filename
    elsif size == :original
      return 'http://publiclaboratory.org/sites/default/files/'+self.filename
    end
  end

end
