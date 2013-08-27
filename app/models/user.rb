class UniqueUsernameValidator < ActiveModel::Validator
  def validate(record)
    if DrupalUsers.find_by_name(record.username) && record.openid_identifier.nil?
      record.errors[:base] << "That username is already taken. If this is your username, you can simply log in to this site."  
    end
  end
end

class User < ActiveRecord::Base
  self.table_name = 'rusers'
  attr_accessible :username, :email, :password, :password_confirmation, :openid_identifier, :key

  acts_as_authentic do |c|
    c.openid_required_fields = [:nickname, 
                                :email] 
  end

  # this doesn't work... we should have a uid field on User
  #has_one :drupal_users, :conditions => proc { ["drupal_users.name =  ?", self.username] }
  has_many :images, :foreign_key => :uid
  validates_with UniqueUsernameValidator, :on => :create

  before_create :create_drupal_user
  after_destroy :destroy_drupal_user

  def create_drupal_user
    if self.drupal_user.nil?
      drupal_user = DrupalUsers.new({
        :name => self.username,
        :pass => rand(100000000000000000000),
        :mail => self.email,
        :mode => 0,
        :sort => 0,
        :threshold => 0,
        :theme => "",
        :signature => "",
        :signature_format => 0,
        :created => DateTime.now.to_i,
        :access => DateTime.now.to_i,
        :login => DateTime.now.to_i,
        :status => 1,
        :timezone => nil,
        :language => "",
        :picture => "",
        :init => "",
        :data => nil,
        :timezone_id => 0,
        :timezone_name => ""
      })
      drupal_user.save!
      self.id = drupal_user.uid
    else
      self.id = DrupalUsers.find_by_name(self.username).uid
    end
  end

  def destroy_drupal_user
    self.drupal_user.destroy
  end
 
  # this is ridiculous. We need to store uid in this model.
  # ...migration is in progress. start getting rid of these calls... 
  def drupal_user
    DrupalUsers.find_by_name(self.username)
  end

  def bio
    self.drupal_user.bio
  end

  def uid
    self.drupal_user.uid
  end

  def lat
    self.drupal_user.lat
  end

  def lon
    self.drupal_user.lon
  end

  # we can revise/improve this for m2m later... 
  def has_role(r)
    self.role == r
  end

  def subscriptions(type = :tag)
    if type == :tag
      TagSelection.find_all_by_user_id self.drupal_user.uid
    end
  end

  def following(tagname)
    tids = DrupalTag.find(:all, :conditions => {:name => tagname}).collect(&:tid)
    TagSelection.find(:all, :conditions => ["tid IN (?) AND user_id = ?", tids, self.uid]).length > 0
  end

  def mapknitter_maps
    # http://mapknitter.org/feeds/author/hagitkeysar
    #begin
    #  RSS::Parser.parse(open('http://mapknitter.org/feeds/author/'+self.username).read, false).items
    #rescue
    #  []
    #end
    []
  end

  private

  def map_openid_registration(registration)
    self.email = registration["email"] if email.blank?
    self.username = registration["nickname"] if username.blank?
  end

end
