class DrupalFile < ActiveRecord::Base
  self.table_name = 'files'
  self.primary_key = 'fid'

  belongs_to :drupal_node, :foreign_key => 'nid', :dependent => :destroy

  def filetype
    self.filename[-3..self.filename.length].downcase
  end

  def is_image?
    (self.filetype == "jpg" || self.filetype == "jpeg" || self.filetype == "gif" || self.filetype == "png") 
  end

  # swap legacy Drupal static routes
  def path(size = :default)
    if self.is_image?
      if size == :thumb
        "https://#{Rails.root}/#{self.filepath.gsub('sites/default/files/','sites/default/files/imagecache/thumb/')}"
      elsif size == :default
        "https://#{Rails.root}/#{self.filepath.gsub('sites/default/files/','sites/default/files/imagecache/default/')}"
      elsif size == :large
        "https://#{Rails.root}/#{self.filepath.gsub('sites/default/files/','sites/default/files/imagecache/default/')}"
      elsif size == :original
        "https://#{Rails.root}/#{self.filepath}"
      end
    else
      "https://#{Rails.root}/#{self.filepath}"
    end
  end

end
