class LocationTag < ActiveRecord::Base
  attr_accessible :lat, :location, :lon, :uid, :country, :state, :city, :nid, :location_privacy
  belongs_to :drupal_users, :foreign_key => :uid
  belongs_to :drupal_node, :foreign_key => :nid


  def self.fetch_location(address)
    geo_location = Geocoder.search("#{address}").first || ""
  end
end
