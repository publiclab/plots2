class ChangeComments < ActiveRecord::Migration
  def up
    rename_column :node, :drupal_comments_count, :comments_count
  end

  def down
    rename_column :node, :comments_count, :drupal_comments_count
  end
end
