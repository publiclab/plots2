class AddCommentsCountToDrupalNode < ActiveRecord::Migration
  def up
    add_column :node, :drupal_comments_count, :integer, default: 0
    DrupalNode.reset_column_information
    DrupalNode.all.each do |node|
      DrupalNode.reset_counters(node.id, :drupal_comments)
    end
  end

  def down
    remove_column :node, :drupal_comments_count
  end
end
