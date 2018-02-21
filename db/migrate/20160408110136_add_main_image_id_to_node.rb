class AddMainImageIdToNode < ActiveRecord::Migration
  def change
    add_column :node, :main_image_id, :integer
  end
end
