class AddTimestampToCommunityTags < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :community_tags, null: true

    NodeTag.where('date != 0').map do |nd|
      nd.update(created_at: Time.at(nd.date).to_datetime, updated_at: DateTime.now)
    end

    date =  Date.new(2000,1,1).to_datetime
    NodeTag.where(created_at: nil).update(created_at: date, updated_at: DateTime.now)



    change_column :community_tags, :created_at, :datetime, null: false
    change_column :community_tags, :updated_at, :datetime, null: false
  end
end
