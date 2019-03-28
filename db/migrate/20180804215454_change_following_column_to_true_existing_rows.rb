class ChangeFollowingColumnToTrueExistingRows < ActiveRecord::Migration[5.2]
  def up
    NodeSelection.all.each do |selection|
      selection.following = true
      selection.save
    end
  end
end
