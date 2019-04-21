class UpdateNodeViewCount < ActiveRecord::Migration[5.2]
  def up
    Node.ids.each do |id|
      node = Node.find(id)
      node.update_columns(views: node.impressionist_count(filter: :ip_address))
    end
  end

  def down
  end
end
