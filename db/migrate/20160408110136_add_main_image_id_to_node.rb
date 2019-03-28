class AddMainImageIdToNode < ActiveRecord::Migration[5.1]
  def change
    add_column :node, :main_image_id, :integer
  end
end
