class DrupalFile < ActiveRecord::Base
  self.table_name = 'files'
  self.primary_key = 'fid'

  belongs_to :node, foreign_key: 'nid', dependent: :destroy

  def filetype
    filename[-3..filename.length].downcase
  end

  def is_image?
    (filetype == 'jpg' || filetype == 'jpeg' || filetype == 'gif' || filetype == 'png')
  end

  # swap legacy Drupal static routes
  def path(size = :default)
    if is_image?
      if size == :thumb
        "/#{filepath.gsub('sites/default/files/', 'sites/default/files/imagecache/thumb/')}"
      elsif size == :default
        "/#{filepath.gsub('sites/default/files/', 'sites/default/files/imagecache/default/')}"
      elsif size == :large
        "/#{filepath.gsub('sites/default/files/', 'sites/default/files/imagecache/default/')}"
      elsif size == :original
        "/#{filepath}"
      end
    else
      "/#{filepath}"
    end
  end
end
