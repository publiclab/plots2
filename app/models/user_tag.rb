class UserTag < ApplicationRecord
  belongs_to :user, foreign_key: :uid

  validates :value, presence: :true
  validates :value, format: { with: /\A[\w\.:-]*\z/, message: 'can only include letters, numbers, and dashes' }
  validates_uniqueness_of :value, :scope => :uid
  before_save :preprocess

  def preprocess
    self.value = value.downcase
  end

  def self.exists?(uid, value)
    UserTag.where(uid: uid, value: value).count.positive?
  end

  def name
    value
  end

  def self.find_with_omniauth(auth)
    find_by(value: "oauth:" + auth['provider'] + ":" + auth['uid'])
  end

  def self.create_with_omniauth(auth, uid)
    create(value: "oauth:" + auth['provider'] + ":" + auth['uid'],
          uid: uid)
  end
  
  def self.create_tag(uid, value)
    create(uid: uid, value: value)
  end

  def self.remove(uid, value)
    UserTag.where(uid: uid, value: value).destroy_all
  end
end
