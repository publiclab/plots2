class AddTimestampToCommunityTags < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :community_tags, null: true

    NodeTag.update_all(created_at: DateTime.now, updated_at: DateTime.now)

    change_column :community_tags, :created_at, :datetime, null: false
    change_column :community_tags, :updated_at, :datetime, null: false
  end
end
