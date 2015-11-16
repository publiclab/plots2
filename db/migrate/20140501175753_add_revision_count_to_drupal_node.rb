class AddRevisionCountToDrupalNode < ActiveRecord::Migration
  def up
    add_column :node, :drupal_node_revisions_count, :integer, default: 0
    DrupalNode.reset_column_information
    DrupalNode.all.each do |node|
      DrupalNode.reset_counters(node.id, :drupal_node_revision)
    end
  end

  def down
    remove_column :node, :drupal_node_revisions_count
  end
end
