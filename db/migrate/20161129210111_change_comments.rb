class ChangeComments < ActiveRecord::Migration[5.1]
  def up
    rename_column :node, :drupal_comments_count, :comments_count
  end

  def down
    rename_column :node, :comments_count, :drupal_comments_count
  end
end
