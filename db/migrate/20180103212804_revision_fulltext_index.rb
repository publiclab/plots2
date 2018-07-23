class RevisionFulltextIndex < ActiveRecord::Migration[5.1]
  def up
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      add_index :node_revisions, [:body, :title], type: :fulltext
      add_index :comments, :comment, type: :fulltext
      add_index :rusers, [:username, :bio], type: :fulltext
    end
  end

  def down
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      remove_index :node_revisions, [:body, :title]
      remove_index :comments, :comment
      remove_index :rusers, [:username, :bio]
    end
  end
end
