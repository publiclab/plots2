class AddMapAuthorship < ActiveRecord::Migration
  def up
    add_column :content_type_map, :authorship, :string, :default => nil
  end

  def down
    remove_column :content_type_map, :authorship
  end
end
