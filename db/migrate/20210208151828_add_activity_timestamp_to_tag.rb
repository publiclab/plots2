class AddActivityTimestampToTag < ActiveRecord::Migration[5.2]
  def change
    add_column :term_data, :activity_timestamp, :datetime
  end
end
