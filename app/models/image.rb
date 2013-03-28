class Image < ActiveRecord::Base
  attr_accessible :uid, :notes, :title, :photo, :nid

  #has_many :comments, :dependent => :destroy
  #has_many :likes, :dependent => :destroy
  #has_many :tags, :dependent => :destroy
  has_one :user, :foreign_key => :uid
  has_one :node, :foreign_key => :nid
  
  has_attached_file :photo, :styles => { :small => "150x150>", :medium => "500x375>", :large => "800x600>" },
                  :url  => "/assets/products/:id/:style/:basename.:extension",
                  :path => ":rails_root/public/assets/products/:id/:style/:basename.:extension"

  validates :uid, :presence => :true
  validates :photo, :presence => :true
  validates :title, :presence => :true, :format => {:with => /\A[a-zA-Z0-9\ -_]+\z/, :message => "Only letters, numbers, and spaces allowed"}, :length => { :maximum => 60 }

  # Paperclip
  has_attached_file :photo,
    :styles => {
      :thumb=> "300x100!",
      :large =>   "800x200!" }

  has_attached_file :baseline,
    :styles => {
      :thumb=> "300x100!",
      :large =>   "800x200!" }
  

end
