class AddDataColumnToUserTag < ActiveRecord::Migration[5.2]
  def change
  	add_column :user_tags, :data, :text
  end
end
