require 'open-uri'

class Image < ApplicationRecord
  belongs_to :user, foreign_key: :uid
  belongs_to :node, foreign_key: :nid

  has_attached_file :photo, styles: { thumb: '200x150>', medium: '500x375>', large: '800x600>' }

  validates :uid, presence: true
  validates :photo, presence: true, unless: :remote_url_provided?
  validates :remote_url, presence: true, if: :remote_url_provided?

  do_not_validate_attachment_file_type :photo_file_name

  before_validation :download_remote_image, if: :remote_url_provided?

  before_post_process :is_image?, :skip_large_gifs

  def is_image?
    %w(jpg jpeg gif png).include?(filetype)
  end

  def skip_large_gifs
    !(filetype == 'gif' && photo_file_size.to_i > 3.megabytes)
  end

  def filetype
    if remote_url_provided? && remote_url[0..9] == "data:image"
      remote_url.split(';').first.split('/').last.downcase
    else
      filename.split('.').last.downcase
    end
  end

  def path(size)
    if is_image? && size == :default
      size = :medium
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
    raise
  end
end
