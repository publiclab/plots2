class DrupalFile < ActiveRecord::Base
  # attr_accessible :title, :body
  self.table_name = 'files'
  self.primary_key = 'fid'

  belongs_to :drupal_node, :foreign_key => 'nid', :dependent => :destroy

  def path(size)
    size = size || :default
    if size == :thumb
      return 'http://publiclaboratory.org/'+self.filepath.gsub('sites/default/files/','sites/default/files/imagecache/thumb/')
    elsif size == :default
      return 'http://publiclaboratory.org/'+self.filepath.gsub('sites/default/files/','sites/default/files/imagecache/default/')
    elsif size == :large
      return 'http://publiclaboratory.org/'+self.filepath.gsub('sites/default/files/','sites/default/files/imagecache/big_but_downloadable/')
    elsif size == :original
      return 'http://publiclaboratory.org/'+self.filepath
    end
  end

end
