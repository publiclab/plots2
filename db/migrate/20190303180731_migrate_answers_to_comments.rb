class MigrateAnswersToComments < ActiveRecord::Migration[5.2]
  def change
    Answer.includes(:comments).all.each do |answer|
      c = Comment.new(nid: answer.nid, uid: answer.uid, comment: answer.content, timestamp: answer.created_at.to_i, thread: "/01", format: 1)
      c.save
      answer.comments.each do |comment|
        comment.aid = 0
        comment.nid = c.nid
        comment.reply_to = c.cid
        comment.save
      end
      answer.delete
    end
  end
end
