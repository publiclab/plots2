class AddCommentViaColumnToComment < ActiveRecord::Migration[5.1]
  def change
  	add_column :comments, :comment_via, :integer, :default => 0
  end
end
