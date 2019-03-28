class RemoveNodeSelectionsOfDeletedNodes < ActiveRecord::Migration[5.1]
  def change
    node_selections = NodeSelection.all
    
    node_selections.each do |node_selection|
      unless Node.exists?(node_selection.nid)
        node_selection.destroy
      end
    end
  end
end
