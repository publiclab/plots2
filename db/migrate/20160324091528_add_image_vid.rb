class AddImageVid < ActiveRecord::Migration
  def up
  	add_column :images, :vid, :integer, :default => 0
  end

  def down
  	remove_column :images, :vid
  end
end
