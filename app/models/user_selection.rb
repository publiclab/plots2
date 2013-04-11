class UserSelection < ActiveRecord::Base
  attr_accessible :following
  self.primary_keys = :self_id, :other_id
  belongs_to :user, :foreign_key => 'self_id'
  belongs_to :other, :class_name => :User, :foreign_key => 'other_id'
end
