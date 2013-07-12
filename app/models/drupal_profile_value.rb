class DrupalProfileValue < ActiveRecord::Base
  attr_accessible :bio, :fid, :uid
  self.table_name = 'profile_values'
  self.primary_key = 'uid'

  belongs_to :drupal_users, :foreign_key => 'uid'
  belongs_to :drupal_profile_field, :foreign_key => 'fid'

end
