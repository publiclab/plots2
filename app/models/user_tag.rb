class UserTag < ApplicationRecord
  belongs_to :user, foreign_key: :uid

  validates :value, presence: :true
  validates :value, format: { with: /\A[\w\.:-]*\z/, message: 'can only include letters, numbers, and dashes' }
  validates_uniqueness_of :value, :scope => :uid
  before_save :preprocess

  DIGEST_DAILY = 0
  DIGEST_WEEKLY = 1

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
end
