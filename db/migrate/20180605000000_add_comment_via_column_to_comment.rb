class AddCommentViaColumnToComment < ActiveRecord::Migration
  def change
  	add_column :comments, :comment_via, :integer, :default => 0
  end
end
