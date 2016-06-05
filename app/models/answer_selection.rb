class AnswerSelection < ActiveRecord::Base
  attr_accessible :liking, :following

  belongs_to :answer, foreign_key: :aid, dependent: :destroy
  belongs_to :drupal_users, foreign_key: :user_id

  def user
    User.find_by_username(DrupalUsers.find_by_uid(self.user_id).name)
  end
end
