class AddColumnReplyToContentInComment < ActiveRecord::Migration[5.1]
  def change
  	add_column :comments, :reply_to_content, :text
  end
end
