class Answer < ApplicationRecord
  include CommentsShared
  include NodeShared

  belongs_to :node, foreign_key: 'nid'
  belongs_to :user, foreign_key: 'uid'
  has_many :answer_selections, foreign_key: 'aid'
  has_many :comments, foreign_key: 'aid', dependent: :destroy

  validates :content, presence: true

  scope :past_week, -> { where("created_at > ?", (Time.now - 7.days)) }
  scope :past_month, -> { where("created_at > ?", (Time.now - 1.months)) }

  def body
    finder = content.gsub(Callouts.const_get(:FINDER), Callouts.const_get(:PRETTYLINKMD))
    finder = finder.gsub(Callouts.const_get(:HASHTAGNUMBER), Callouts.const_get(:NODELINKMD))
    finder.gsub(Callouts.const_get(:HASHTAG), Callouts.const_get(:HASHLINKMD))
  end

  def body_markdown
    RDiscount.new(body, :autolink).to_html
  end

  # users who like this answer
  def likers
    answer_selections
      .joins(:user)
      .references(:rusers)
      .where(liking: true)
      .where('rusers.status': 1)
      .collect(&:user)
  end

  def answer_notify(current_user)
    # notify question author
    if current_user.uid != node.author.uid
      AnswerMailer.notify_question_author(node.author, self).deliver_now
    end
    users_with_everything_tag = Tag.followers('everything')
    uids = (node.answers.collect(&:uid) + node.likers.collect(&:uid) + users_with_everything_tag.collect(&:uid)).uniq
    # notify other answer authors and users who liked the question
    User.where(id: uids).each do |user|
      if (user.uid != current_user.uid) && (user.uid != node.author.uid)
        AnswerMailer.notify_answer_likers_author(user, self).deliver_now
      end
    end
  end
end
