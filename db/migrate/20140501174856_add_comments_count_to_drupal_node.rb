class AddCommentsCountToDrupalNode < ActiveRecord::Migration
  def up
    add_column :node, :drupal_comments_count, :integer, default: 0
    Node.reset_column_information
    Node.all.each do |node|
      Node.reset_counters(node.id, :drupal_comments)
    end
  end

  def down
    remove_column :node, :drupal_comments_count
  end
end
