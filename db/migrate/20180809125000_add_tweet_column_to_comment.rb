class AddTweetColumnToComment < ActiveRecord::Migration[5.2]
  def change
  	add_column :comments, :tweet_id, :string
  end
end
