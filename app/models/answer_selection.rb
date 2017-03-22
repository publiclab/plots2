class AnswerSelection < ActiveRecord::Base
  attr_accessible :liking, :following, :user_id, :aid

  belongs_to :answer, foreign_key: :aid, dependent: :destroy
  belongs_to :drupal_users, foreign_key: :user_id

  def user
    User.find_by_username(DrupalUsers.find_by_uid(user_id).name)
  end

  def self.set_likes(uid, aid, value)
    like = where(user_id: uid, aid: aid).first_or_create
    like.liking = value
    if like.liking_changed?
      answer = Answer.find(aid)
      if like.liking
        answer.cached_likes += 1
      else
        answer.cached_likes -= 1
      end
      like.save
      answer.save
    end
    like.liking
  end
end
