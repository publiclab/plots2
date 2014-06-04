class AddPathToDrupalNode < ActiveRecord::Migration
  def up
    add_column :node, :path, :string

    dsts = ActiveRecord::Base.connection.execute('select dst, src from url_alias;')
    dsts.each do |dst, src|
      node = DrupalNode.find(src.split('/')[1])
      node.path = "/#{dst}"
      node.save
    end

    drop_table :url_alias
  end
    

  def down
    remove_column :node, :path

    create_table :url_alias, :primary_key => "pid" do |t|
      t.string :src, :limit => 128, default: "", :null => false
      t.string :dst, :limit => 128, default: "", :null => false
      t.string :language, :limit => 12, :default => "", :null => false
    end
  end
end
