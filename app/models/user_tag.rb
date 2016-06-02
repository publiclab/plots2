class UserTag < ActiveRecord::Base
  attr_accessible :uid, :value
  belongs_to :user, :foreign_key => :uid

  def self.exists? uid, value
    UserTag.where(uid: uid, value: value).count > 0
  end
end
