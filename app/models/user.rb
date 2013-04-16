class User < ActiveRecord::Base
  self.table_name = 'rusers'
  attr_accessible :username, :email, :password, :password_confirmation, :openid_identifier

  acts_as_authentic do |c|
    c.openid_required_fields = [:nickname, 
                                :email] 
  end

  # this doesn't work... we should have a uid field on User
  #has_one :drupal_users, :conditions => proc { ["drupal_users.name =  ?", self.username] }
  has_many :images, :foreign_key => :uid

  # this is ridiculous. We need to store uid in this model.
  def drupal_user
    DrupalUsers.find_by_name(self.username)
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

  def subscriptions(type = :tag)
    if type == :tag
      TagSelection.find_all_by_user_id self.drupal_user.uid
    end
  end

  private

  def map_openid_registration(registration)
    self.email = registration["email"] if email.blank?
    self.username = registration["nickname"] if username.blank?
  end

end
