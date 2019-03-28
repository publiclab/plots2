class AddDefaultValueToCommentStatus < ActiveRecord::Migration[5.1]
  def change
    change_column :comments, :status, :integer, default: 1
    Comment.update_all ["status = ?", 1]
  end
end
