class CreateLikeAndFollow < ActiveRecord::Migration
  def up
    # dictionary of (user.id, drupal_tag.id) mapping to (following)
    # no need for wasteful primary key when the unique index recreates a
    # composite PK using (user.id, drupal_tag.id).
    # In English: track user follow tag
    create_table :tagselections, :id => false do |t|
      t.integer :user_id
      t.integer :tid
      t.boolean :following
    end
    add_index :tagselections, [:user_id, :tid], :unique => true

    # track user follow user
    create_table :userselections, :id => false do |t|
      t.integer :self_id
      t.integer :other_id
      t.boolean :following
    end
    add_index :userselections, [:self_id, :other_id], :unique => true

    # track user follow node
    # track user like node
    create_table :nodeselections, :id => false do |t|
      t.integer :user_id
      t.integer :nid
      t.boolean :following
      t.boolean :liking
    end
    add_index :nodeselections, [:user_id, :nid], :unique => true

    # cache the like count on nodes to save time on calling count()
    change_table :node do |t|
      t.integer :cached_likes, :default => 0
    end
  end

  def down
    drop_view :selections
    remove_column :node, :cached_likes
    drop_table :nodeselections
    drop_table :userselections
    drop_table :tagselections
  end
end
