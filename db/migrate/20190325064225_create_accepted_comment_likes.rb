class CreateAcceptedCommentLikes < ActiveRecord::Migration[5.2]
  def change
    def up
      answers = Answer.where(accepted: true)
      timestamp_to_answer_id = answers.group('created_at').minimum('id')
                                         .inject({}) {|hash, (key, value)| hash[key.to_i] = value; hash}

      Comment.where(timestamp: timestamp_to_answer_id.keys).or(Comment.where(comment: answers.pluck(:content))).each do |c|
        c.likes.create(emoji_type: "Accepted")
      end
    end


    def down
    end
  end
end
