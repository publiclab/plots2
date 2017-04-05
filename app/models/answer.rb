class Answer < ActiveRecord::Base
  include NodeShared, CommentsShared # common methods for node-like and comment-like models

  attr_accessible :uid, :nid, :content, :cached_likes, :created_at, :updated_at

  belongs_to :node, foreign_key: 'nid', dependent: :destroy
  belongs_to :drupal_users, foreign_key: 'uid'
  has_many :answer_selections, foreign_key: 'aid'
  has_many :comments, foreign_key: 'aid'

  validates :content, presence: true

  def body
    finder = content.gsub(Callouts.const_get(:FINDER), Callouts.const_get(:PRETTYLINKMD))
    finder.gsub(Callouts.const_get(:HASHTAG), Callouts.const_get(:HASHLINKMD))
  end

  # users who like this answer
  def likers
    answer_selections
      .joins(:drupal_users)
      .where(liking: true)
      .where('users.status = ?', 1)
      .collect(&:user)
  end

  def answer_notify(current_user)
    # notify question author
    if current_user.uid != node.author.uid
      AnswerMailer.notify_question_author(node.author, self).deliver
    end

    uids = (node.answers.collect(&:uid) + node.likers.collect(&:uid)).uniq

    # notify other answer authors and users who liked the question
    DrupalUsers.where('uid IN (?)', uids).each do |user|
      if (user.uid != current_user.uid) && (user.uid != node.author.uid)
        AnswerMailer.notify_answer_likers_author(user.user, self).deliver
      end
    end
  end
end
