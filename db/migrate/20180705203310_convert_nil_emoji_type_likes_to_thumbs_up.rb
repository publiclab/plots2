class ConvertNilEmojiTypeLikesToThumbsUp < ActiveRecord::Migration[5.2]
  def up
    Like.where(emoji_type: nil).each do |like|
      like.emoji_type = "ThumbsUp"
      like.save({})
    end
  end

  def down
  end
end
