class AddDefaultValueToCommentStatus < ActiveRecord::Migration
  def change
    change_column :comments, :status, :integer, default: 1
    Comment.update_all ["status = ?", 1]
  end
end
