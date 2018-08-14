class AddFullTextIndexOnUsername < ActiveRecord::Migration[5.2]
  def up
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      add_index :rusers, :username, type: :fulltext, name: 'rusers_username_fulltext_idx'
    end
  end

  def down
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      remove_index :rusers, name: 'rusers_username_fulltext_idx'
    end
  end
end
