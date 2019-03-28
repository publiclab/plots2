class AddMapAuthorship < ActiveRecord::Migration[5.1]
  def up
    unless column_exists? "content_type_map", :authorship
      add_column :content_type_map, :authorship, :string, :default => nil
    end
  end

  def down
    remove_column :content_type_map, :authorship
  end
end
