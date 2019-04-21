require 'open-uri'

class Image < ApplicationRecord
  belongs_to :user, foreign_key: :uid
  belongs_to :node, foreign_key: :nid

  has_attached_file :photo, styles: { thumb: '200x150>', medium: '500x375>', large: '800x600>' } # ,
  #:url  => "/system/images/photos/:id/:style/:basename.:extension",
  #:path => ":rails_root/public/system/images/photos/:id/:style/:basename.:extension"

  validates :uid, presence: true
  validates :photo, presence: true, unless: :remote_url_provided?
  do_not_validate_attachment_file_type :photo_file_name
  # disabling type validation as we support many more such as PDF, SVG, see /app/views/editor/rich.html.erb#L232
  # validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/jpg', 'image/gif']
  # validates_attachment_content_type :photo_file_name, :content_type => %w(image/jpeg image/jpg image/png)
  # validates :title, :presence => true, :format => {:with => /\A[a-zA-Z0-9\ -_]+\z/, :message => "Only letters, numbers, and spaces allowed"}, :length => { :maximum => 60 }

  before_validation :download_remote_image, if: :remote_url_provided?
  validates :remote_url, presence: true, if: :remote_url_provided? # , :message => "is invalid or inaccessible" # this message thing is old-style rails 2.3.x
  before_post_process :is_image?, :skip_large_gifs

  def is_image?
    (filetype == 'jpg' || filetype == 'jpeg' || filetype == 'gif' || filetype == 'png')
  end

  def skip_large_gifs
    ! (filetype == 'gif' && photo_file_size.to_i > 3.megabytes)
  end

  def filetype
    if remote_url_provided? && remote_url[0..9] == "data:image"
      # data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
      remote_url.split(';').first.split('/').last.downcase
    else
      filename.split('.').last.downcase
    end
  end

  def path(size = :medium)
    if is_image?
      size = :medium if size == :default
    else
      size = :original
    end
    photo.url(size)
  end

  def shortlink
    "/i/#{id}"
  end

  def filename
    photo_file_name
  end

  private

  def absolute_uri
    Rails.env.production? ? 'https://publiclab.org' : ''
  end

  # all subsequent code from http://trevorturk.com/2008/12/11/easy-upload-via-url-with-paperclip/

  def remote_url_provided?
    !remote_url.blank?
  end

  def download_remote_image
    self.photo = do_download_remote_image
    self.remote_url = remote_url
  end

  def do_download_remote_image
    io = open(URI.parse(remote_url)).base_uri.path.split('/').last

    io.blank? ? nil : io
  rescue StandardError
    # Let's sign up with Rollbar's free service to get insights on
    # on what errors we get so we can address them accordingly
    raise
  end
end
