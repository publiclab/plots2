class RevisionFulltextIndex < ActiveRecord::Migration
  def up
    add_index :node_revisions, [:body, :title], name: 'revision_fulltext', type: :fulltext if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
  end

  def down
    remove_index :node_revisions, [:body, :title], name: 'revision_fulltext' if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
  end
end
