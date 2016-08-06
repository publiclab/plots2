class LocationTag < ActiveRecord::Base
  attr_accessible :lat, :location, :lon, :uid, :country, :state, :city
  belongs_to :drupal_users, :foreign_key => :uid
  belongs_to :drupal_node, :foreign_key => :nid
end
