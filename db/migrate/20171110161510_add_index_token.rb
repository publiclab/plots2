class AddIndexToken < ActiveRecord::Migration
  def up
    add_index "rusers", ["persistence_token"], :name => "index_rusers_on_persistence_token"
  end

  def down
    remove_index "rusers", ["persistence_token"]
  end
end
