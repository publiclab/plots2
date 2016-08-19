class AddSlugToNodes < ActiveRecord::Migration
  def up
    add_column :node, :slug, :string
    add_index :node, :slug
  end

  def down
    remove_index :node, :slug
    remove_column :node, :slug
  end
end
