class AddDstToDrupalNode < ActiveRecord::Migration
  def up
    add_column :node, :dst, :string

    DrupalUrlAlias.all.each do |url_alias|
      node = url_alias.node
      node.dst = url_alias.dst
      node.save
    end

     drop_table :url_alias
  end
    

  def down
    remove_column :node, :dst

    create_table :url_alias, :primary_key => "pid" do |t|
      t.string :src, :limit => 128, default: "", :null => false
      t.string :dst, :limit => 128, default: "", :null => false
      t.string :language, :limit => 12, :default => "", :null => false
    end
  end
end
