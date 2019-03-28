class ChangeStatusOfComments < ActiveRecord::Migration[5.2]
  def up
    Comment.all.each do |comment|
      comment.status = 1
      comment.save
    end
  end

  def down
  end
end
