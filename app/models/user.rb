class User < ActiveRecord::Base
  self.table_name = 'rusers'
  attr_accessible :username, :email, :password, :password_confirmation, :openid_identifier

  acts_as_authentic do |c|
    c.openid_required_fields = [:nickname, 
                                :email] 
  end

  private

  def map_openid_registration(registration)
    self.email = registration["email"] if email.blank?
    self.username = registration["nickname"] if username.blank?
  end
end
