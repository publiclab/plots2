class DrupalProfileField < ActiveRecord::Base
  self.table_name = 'profile_fields'

  has_many :drupal_profile_values, :foreign_key => 'fid'

  def self.inheritance_column
    "rails_type"
  end

end
