class Answer < ActiveRecord::Base
  attr_accessible :uid, :nid, :content, :cached_likes, :created_at, :updated_at

  belongs_to :drupal_node, foreign_key: 'nid', dependent: :destroy
  belongs_to :drupal_users, foreign_key: 'uid'
  has_many :answer_selections, foreign_key: 'aid'
  has_many :drupal_comments, foreign_key: 'aid'

  validates :content, presence: true

  def body
    finder = self.content.gsub(Callouts.const_get(:FINDER), Callouts.const_get(:PRETTYLINKMD))
    finder.gsub(Callouts.const_get(:HASHTAG), Callouts.const_get(:HASHLINKMD))
  end

  def body_email
    self.body.gsub(/([\s|"|'|\[|\(])(\/\/)([\w]?\.?publiclab.org)/, '\1https://\3')
  end

  def author
    DrupalUsers.find_by_uid self.uid
  end

  def node
    self.drupal_node
  end

  def likes
    self.cached_likes
  end

  # users who like this answer
  def likers
    self.answer_selections
        .joins(:drupal_users)
        .where(liking: true)
        .where('users.status = ?', 1)
        .collect(&:user)
  end

  def liked_by(uid)
    self.likers.collect(&:uid).include?(uid)
  end

  def comments
    self.drupal_comments
        .order('timestamp DESC')
  end

  def answer_notify(current_user)
    # notify question author
    if current_user.uid != self.author.uid
      AnswerMailer.notify_question_author(self.author, self).deliver
    end

    uids =  (self.node.answers.collect(&:uid) + self.node.likers.collect(&:uid)).uniq

    # notify other answer authors and users who liked the question
    DrupalUsers.where("uid IN (?)", uids).each do |user|
      if user.uid != (current_user.uid && self.author.uid)
        AnswerMailer.notify_answer_likers_author(user.user, self).deliver
      end
    end
  end 
end
