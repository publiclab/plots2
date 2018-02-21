class NodePageviews < ActiveRecord::Migration
  def up
    add_column :node, :legacy_views, :integer, default: 0
    add_column :node, :views, :integer, default: 0
    if defined? DrupalNodeCounter
      DrupalNodeCounter.all.each do |counter|
        n = DrupalNode.find_by_nid(counter.nid)
        n.update_attribute('views', counter.totalcount) if n
      end
    end
    # later we'll need to: drop_table :node_counter
  end

  def down
    # we don't backwards-migrate totalcount from views
    remove_column :node, :legacy_views
    remove_column :node, :views
  end
end
