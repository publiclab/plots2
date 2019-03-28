class UserTag < ApplicationRecord
  serialize :data
  belongs_to :user, foreign_key: :uid
  validates :value, presence: true
  validates :value, format: { with: /\A[\w\.:-]*\z/, message: 'can only include letters, numbers, and dashes' }
  validates_uniqueness_of :value, scope: :uid
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
          uid: uid, data: auth.to_hash)
  end

  def self.remove_if_exists(uid, value)
    if exists?(uid, value)
      UserTag.where(uid: uid, value: value).destroy_all
    end
  end

  def self.create_if_absent(uid, value)
    unless exists?(uid, value)
      UserTag.create(uid: uid, value: value)
    end
  end
end
