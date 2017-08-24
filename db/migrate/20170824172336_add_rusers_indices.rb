class AddRusersIndices < ActiveRecord::Migration
  def up
    add_index "rusers", ["status"], :name => "index_rusers_on_status"
  end

  def down
    remove_index :rusers, :status
  end
end
