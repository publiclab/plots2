class RenameLongColumnInUsers < ActiveRecord::Migration[5.1]
  def up
    rename_column :location_tags, :long, :lon
  end

  def down
  	rename_column :location_tags, :lon, :long
  end
end
