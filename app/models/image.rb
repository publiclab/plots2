class Image < ActiveRecord::Base
  attr_accessible :uid, :notes, :title, :photo, :nid

  #has_many :comments, :dependent => :destroy
  #has_many :likes, :dependent => :destroy
  #has_many :tags, :dependent => :destroy
  has_one :user, :foreign_key => :uid
  has_one :node, :foreign_key => :nid
  
  has_attached_file :photo, :styles => { :thumb => "200x150>", :medium => "500x375>", :large => "800x600>" }#,
                  #:url  => "/system/images/photos/:id/:style/:basename.:extension",
                  #:path => ":rails_root/public/system/images/photos/:id/:style/:basename.:extension"

  validates :uid, :presence => :true
  validates :photo, :presence => :true
  validates :title, :presence => :true, :format => {:with => /\A[a-zA-Z0-9\ -_]+\z/, :message => "Only letters, numbers, and spaces allowed"}, :length => { :maximum => 60 }

  before_post_process :is_image?

  def is_image?
    (self.filetype == "jpg" || self.filetype == "jpeg" || self.filetype == "gif" || self.filetype == "png") 
  end

  def filetype
    self.filename[-3..self.filename.length].downcase
  end

  def path(size = :medium)
    if self.is_image?
      size = :medium if size == :default
    else
      size = :original
    end
    if Rails.env == "production"
      'http://i.publiclab.org'+self.photo.url(size)
    else
      self.photo.url(size).gsub('http://i.publiclab.org','')
    end
  end

  def filename
    self.photo_file_name
  end

end
