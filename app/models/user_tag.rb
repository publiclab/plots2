class UserTag < ActiveRecord::Base
  attr_accessible :uid, :value
  belongs_to :user, foreign_key: :uid

  validates :value, presence: :true
  validates :value, format: { with: /\A[\w\.:-]*\z/, message: 'can only include letters, numbers, and dashes' }
  validates_uniqueness_of :value, :scope => :uid
  before_save :preprocess

  def preprocess
    self.value = self.value.downcase
  end

  def self.exists?(uid, value)
    UserTag.where(uid: uid, value: value).count.positive?
  end

  def name
    self.value
  end

  def self.find_with_omniauth(auth)
    find_by(value: auth['provider'] + ":" + auth['uid'])
  end

  def self.create_with_omniauth(auth, uid)
    create(value: auth['provider'] + ":" + auth['uid'],
          uid: uid)
  end

end
