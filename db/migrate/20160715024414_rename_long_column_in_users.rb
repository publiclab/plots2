class RenameLongColumnInUsers < ActiveRecord::Migration
  def up
    rename_column :location_tags, :long, :lon
  end

  def down
  	rename_column :location_tags, :lon, :long
  end
end
