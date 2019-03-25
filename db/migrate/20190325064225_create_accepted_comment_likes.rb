class CreateAcceptedCommentLikes < ActiveRecord::Migration[5.2]
  def change
    def up
      timestamp_to_answer_id = Answer.where(accepted: true).group('created_at').minimum('id')
                                         .inject({}) {|hash, (key, value)| hash[key.to_i] = value; hash}

      Comment.where(timestamp: timestamp_to_answer_id.keys).each do |c|
        c.likes.create(emoji_type: "Accepted")
      end
    end

    def down
    end
  end
end
