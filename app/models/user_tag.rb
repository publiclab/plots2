class UserTag < ActiveRecord::Base
  attr_accessible :uid, :value
  belongs_to :user, :foreign_key => :uid, :dependent => :destroy
end
