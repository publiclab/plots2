class NodePageviews < ActiveRecord::Migration
  def up
    add_column :node, :legacy_views, :integer, default: 0
    add_column :node, :views, :integer, default: 0
    DrupalNodeCounter.all.each do |counter|
      DrupalNode.find(counter.nid).update_attribute(views: counter.totalcount)
    end
    # later we'll need to: drop_table :node_counter
  end

  def down
    # we don't backwards-migrate totalcount from views
    remove_column :node, :legacy_views
    remove_column :node, :views
  end
end
