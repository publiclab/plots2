class AddRusersIndices < ActiveRecord::Migration
  def up
    add_index "rusers", ["status"], name: "index_rusers_on_status"
    add_index "rusers", ["created_at"], name: "index_rusers_created_at"
  end

  def down
    remove_index :rusers, :status
    remove_index :rusers, :created_at
  end
end
