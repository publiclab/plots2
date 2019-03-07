class MigrateAnswersToComments < ActiveRecord::Migration[5.2]
  def up
    Answer.includes(:comments, :answer_selections).all.each do |answer|
      c = Comment.new(nid: answer.nid, uid: answer.uid, comment: answer.content, timestamp: answer.created_at.to_i, thread: "/01", format: 1)
      c.save

      answer.answer_selections.each do |answer_selection|
        c.likes.create(emoji_type: "ThumbsUp", user_id: answer_selection.user_id) if answer_selection.liking
      end

      answer.comments.each do |comment|
        comment.aid = 0
        comment.nid = c.nid
        comment.reply_to = c.cid
        comment.save
      end
    end
  end

  def down
  end
end
