class RenameLikeAndFollow < ActiveRecord::Migration
  def up
    remove_index :nodeselections, [:user_id, :nid]
    drop_table :nodeselections
    remove_index :userselections, [:self_id, :other_id]
    drop_table :userselections
    remove_index :tagselections, [:user_id, :tid]
    drop_table :tagselections

    # See 20130402 migration for details, this is copypasta
    create_table :tag_selections, :id => false do |t|
      t.integer :user_id
      t.integer :tid
      t.boolean :following, :default => false
    end
    add_index :tag_selections, [:user_id, :tid], :unique => true

    create_table :user_selections, :id => false do |t|
      t.integer :self_id
      t.integer :other_id
      t.boolean :following, :default => false
    end
    add_index :user_selections, [:self_id, :other_id], :unique => true

    create_table :node_selections, :id => false do |t|
      t.integer :user_id
      t.integer :nid
      t.boolean :following, :default => false
      t.boolean :liking, :default => false
    end
    add_index :node_selections, [:user_id, :nid], :unique => true
  end

  def down
    remove_index :node_selections, [:user_id, :nid]
    drop_table :node_selections
    remove_index :user_selections, [:self_id, :other_id]
    drop_table :user_selections
    remove_index :tag_selections, [:user_id, :tid]
    drop_table :tag_selections

    # Restore the previous tables
    create_table :tagselections, :id => false do |t|
      t.integer :user_id
      t.integer :tid
      t.boolean :following
    end
    add_index :tagselections, [:user_id, :tid], :unique => true

    create_table :userselections, :id => false do |t|
      t.integer :self_id
      t.integer :other_id
      t.boolean :following
    end
    add_index :userselections, [:self_id, :other_id], :unique => true

    create_table :nodeselections, :id => false do |t|
      t.integer :user_id
      t.integer :nid
      t.boolean :following
      t.boolean :liking
    end
    add_index :nodeselections, [:user_id, :nid], :unique => true
  end

end
