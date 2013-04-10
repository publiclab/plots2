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

  def uid
    DrupalUsers.find_by_name(self.username).uid
  end

  def lat
    DrupalUsers.find_by_name(self.username).lat
  end

  def lon
    DrupalUsers.find_by_name(self.username).lon
  end

  private

  def map_openid_registration(registration)
    self.email = registration["email"] if email.blank?
    self.username = registration["nickname"] if username.blank?
  end

end
