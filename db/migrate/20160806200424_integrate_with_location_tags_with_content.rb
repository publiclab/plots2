class IntegrateWithLocationTagsWithContent < ActiveRecord::Migration
  def up
    add_column :location_tags, :nid, :integer
    add_column :location_tags, :location_privacy, :boolean
  end

  def down
    remove_column :location_tags, :nid
    remove_column :location_tags, :location_privacy
  end
end
