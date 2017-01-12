class CreateLikeAndFollow < ActiveRecord::Migration
  def up
    # dictionary of (user.id, tag.id) mapping to (following)
    # no need for wasteful primary key when the unique index recreates a
    # composite PK using (user.id, tag.id).
    # In English: track user follow tag
    unless table_exists? "tagselections"
      create_table :tagselections, :id => false do |t|
        t.integer :user_id
        t.integer :tid
        t.boolean :following
      end
    end

    unless index_exists? "tagselections", [:user_id, :tid], unique: true
      add_index :tagselections, [:user_id, :tid], :unique => true
    end

    # track user follow user
    unless table_exists? "userselections"
      create_table :userselections, :id => false do |t|
        t.integer :self_id
        t.integer :other_id
        t.boolean :following
      end
    end

    unless index_exists? "userselections", [:self_id, :other_id], unique: true
      add_index :userselections, [:self_id, :other_id], :unique => true
    end

    # track user follow node
    # track user like node
    unless table_exists? "nodeselections"
      create_table :nodeselections, :id => false do |t|
        t.integer :user_id
        t.integer :nid
        t.boolean :following
        t.boolean :liking
      end
    end
    
    #unless index_exists? "nodeselections", [:user_id, :nid], unique: true
      add_index :nodeselections, [:user_id, :nid], :unique => true
    #end

    # cache the like count on nodes to save time on calling count()
    unless column_exists? "node", "cached_likes"
      change_table :node do |t|
        t.integer :cached_likes, :default => 0
      end
    end
  end

  def down
    remove_column :node, :cached_likes
    remove_index :nodeselections, [:user_id, :nid]
    drop_table :nodeselections
    remove_index :userselections, [:self_id, :other_id]
    drop_table :userselections
    remove_index :tagselections, [:user_id, :tid]
    drop_table :tagselections
  end
end
