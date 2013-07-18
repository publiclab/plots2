class DrupalFile < ActiveRecord::Base
  # attr_accessible :title, :body
  self.table_name = 'files'
  self.primary_key = 'fid'

  belongs_to :drupal_node, :foreign_key => 'nid', :dependent => :destroy

  def filetype
    self.filename[-3..self.filename.length].downcase
  end

  def is_image?
    (self.filetype == "jpg" || self.filetype == "jpeg" || self.filetype == "gif" || self.filetype == "png") 
  end

  def path(size = :default)
    if self.is_image?
      if size == :thumb
        return 'http://old.publiclab.org/'+self.filepath.gsub('sites/default/files/','sites/default/files/imagecache/thumb/')
      elsif size == :default
        return 'http://old.publiclab.org/'+self.filepath.gsub('sites/default/files/','sites/default/files/imagecache/default/')
      elsif size == :large
        return 'http://old.publiclab.org/'+self.filepath.gsub('sites/default/files/','sites/default/files/imagecache/big_but_downloadable/')
      elsif size == :original
        return 'http://old.publiclab.org/'+self.filepath
      end
    else
      "http://old.publiclab.org/"+self.filepath
    end
  end

end
