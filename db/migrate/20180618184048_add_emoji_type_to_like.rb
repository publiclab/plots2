class AddEmojiTypeToLike < ActiveRecord::Migration[5.1]
  def change
  	add_column :likes, :emoji_type, :string
  end
end
