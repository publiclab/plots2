require Rails.root + "lib/authlogic_openid/authlogic_openid/version.rb"
require Rails.root + "lib/authlogic_openid/authlogic_openid/acts_as_authentic.rb"
require Rails.root + "lib/authlogic_openid/authlogic_openid/session.rb"

ActiveRecord::Base.send(:include, AuthlogicOpenid::ActsAsAuthentic)
Authlogic::Session::Base.send(:include, AuthlogicOpenid::Session)
