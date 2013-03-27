class DrupalFile < ActiveRecord::Base
  # attr_accessible :title, :body
  self.table_name = 'files'
  self.primary_key = 'fid'

  belongs_to :drupal_node, :foreign_key => 'nid'

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
