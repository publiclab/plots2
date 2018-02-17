class RemoveNodeselectionsOfDeletedNodes < ActiveRecord::Migration
  def change
    nodeSelections=NodeSelection.all
    nodeSelections.each do |nodeselection|
      if Node.exists?(nodeselection.nid)
      else
        nodeselection.destroy
      end
    end
  end
end
