class RemoveNodeLegacyViews < ActiveRecord::Migration[5.2]
  def up
    Node.ids.each do |id|
      node = Node.find(id)
      node.update_columns(views: node.views + node.legacy_views)
    end
    remove_column :node, :legacy_views
  end

  def down
    add_column :node, :legacy_views, :integer, default: 0
  end
end
