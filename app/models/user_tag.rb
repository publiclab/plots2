class UserTag < ActiveRecord::Base
  attr_accessible :uid, :value
  belongs_to :user, foreign_key: :uid
  validates_format_of :value, with: /\A[a-z]*:[a-zA-Z0-9]*\Z/, message: 'field contains invalid input'

  def self.exists?(uid, value)
    UserTag.where(uid: uid, value: value).count > 0
  end
end
