require 'open-uri'

class Image < ActiveRecord::Base
  attr_accessible :uid, :notes, :title, :photo, :nid, :remote_url

  #has_many :comments, :dependent => :destroy
  #has_many :likes, :dependent => :destroy
  #has_many :tags, :dependent => :destroy
  belongs_to :user, :foreign_key => :uid
  belongs_to :node, :foreign_key => :nid
  
  has_attached_file :photo, :styles => { :thumb => "200x150>", :medium => "500x375>", :large => "800x600>" }#,
                  #:url  => "/system/images/photos/:id/:style/:basename.:extension",
                  #:path => ":rails_root/public/system/images/photos/:id/:style/:basename.:extension"

  validates :uid, :presence => :true
  validates :photo, :presence => :true, :unless => :remote_url_provided?
  do_not_validate_attachment_file_type :photo_file_name
  #validates_attachment_content_type :photo_file_name, :content_type => %w(image/jpeg image/jpg image/png)
  #validates :title, :presence => :true, :format => {:with => /\A[a-zA-Z0-9\ -_]+\z/, :message => "Only letters, numbers, and spaces allowed"}, :length => { :maximum => 60 }

  before_validation :download_remote_image, :if => :remote_url_provided?
  validates :remote_url, :presence => true, :if => :remote_url_provided?#, :message => "is invalid or inaccessible" # this message thing is old-style rails 2.3.x
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
      '//i.publiclab.org'+self.photo.url(size)
    else
      self.photo.url(size).gsub('//i.publiclab.org','')
    end
  end

  def filename
    self.photo_file_name
  end

private
  # all subsequent code from http://trevorturk.com/2008/12/11/easy-upload-via-url-with-paperclip/

  def remote_url_provided?
    !self.remote_url.blank?
  end

  def download_remote_image
    self.photo = do_download_remote_image
    puts remote_url
    puts "finishes to do_download"
    self.remote_url = remote_url
  end

  def do_download_remote_image
    io = open(URI.parse(remote_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno:ENOENT, OpenURI:HTTPError, etc...)
    puts "had to be rescued"
  end

end
