class LocationTag < ActiveRecord::Base
  attr_accessible :lat, :location, :long, :uid
  belongs_to :user, :foreign_key => :uid
end
