class ChangeDefaultInNodeSelection < ActiveRecord::Migration[5.2]
  def change
    change_column_default :node_selections, :following, true
  end
end
