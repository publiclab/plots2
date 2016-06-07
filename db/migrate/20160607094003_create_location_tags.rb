class CreateLocationTags < ActiveRecord::Migration
  def up
    unless table_exists? "location_tags"
      create_table :location_tags do |t|
        t.integer :uid
        t.string :location

        t.timestamps
      end

      add_column :location_tags, :lat, :decimal, :precision => 15, :scale => 10
      add_column :location_tags, :long, :decimal, :precision => 15, :scale => 10
    end
  end

  def down
    drop_table :location_tags
  end
end
