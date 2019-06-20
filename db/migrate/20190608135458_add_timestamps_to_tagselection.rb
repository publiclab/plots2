class AddTimestampsToTagselection < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :tag_selections, null: true

    date =  Date.new(2000,1,1).to_datetime
    TagSelection.update_all(created_at: date, updated_at: DateTime.now)


    change_column :tag_selections, :created_at, :datetime, null: false
    change_column :tag_selections, :updated_at, :datetime, null: false
  end
end
