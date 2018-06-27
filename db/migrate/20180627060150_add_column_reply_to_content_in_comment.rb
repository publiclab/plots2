class AddColumnReplyToContentInComment < ActiveRecord::Migration[5.1]
  def change
  	add_column :comments, :extra_content, :text
  end
end
