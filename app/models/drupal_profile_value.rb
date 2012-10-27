class DrupalProfileValue < ActiveRecord::Base
  # attr_accessible :title, :body
  self.table_name = 'profile_values'

  belongs_to :drupal_users, :foreign_key => 'uid'

end
