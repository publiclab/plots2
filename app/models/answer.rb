class Answer < ApplicationRecord
  include CommentsShared
  include NodeShared
  extend RawStats

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
end
