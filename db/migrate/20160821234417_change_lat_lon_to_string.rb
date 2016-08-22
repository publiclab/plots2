class ChangeLatLonToString < ActiveRecord::Migration
  def change
    change_column :location_tags, :lat, :text
    change_column :location_tags, :lon, :text
  end
end
