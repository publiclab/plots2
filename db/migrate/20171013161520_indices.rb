class Indices < ActiveRecord::Migration
  def up
    add_index "rusers", ["email"], :name => "index_rusers_on_email"
    add_index "users", ["uid"], :name => "index_users_uid"
    add_index "node_revisions", ["timestamp"], :name => "index_node_revisions_timestamp"
  end

  def down
    remove_index(:rusers, :email)
    remove_index(:users, :uid)
    remove_index(:node_revisions, :timestamp)
  end
end
