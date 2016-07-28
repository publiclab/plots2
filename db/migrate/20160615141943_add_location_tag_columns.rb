class AddLocationTagColumns < ActiveRecord::Migration
  def up
    add_column :location_tags, :country, :string
    add_column :location_tags, :state, :string
    add_column :location_tags, :city, :string
  end

  def down
    remove_column :location_tags, :country
    remove_column :location_tags, :state
    remove_column :location_tags, :city
  end
end
