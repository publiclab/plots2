class Comment < ApplicationRecord
  include CommentsShared # common methods for comment-like models


  belongs_to :node, foreign_key: 'nid', touch: true, counter_cache: true
                    # dependent: :destroy, counter_cache: true
  belongs_to :drupal_user, foreign_key: 'uid'
  belongs_to :answer, foreign_key: 'aid'

  validates :comment, presence: true

  self.table_name = 'comments'
  self.primary_key = 'cid'

  def self.inheritance_column
    'rails_type'
  end

  def self.search(query)
    Comment.where('MATCH(comment) AGAINST(?)', query)
      .where(status: 1)
  end

  def self.comment_weekly_tallies(span = 52, time = Time.now)
    weeks = {}
    (0..span).each do |week|
      weeks[span - week] = Comment.select(:timestamp)
        .where(timestamp: time.to_i - week.weeks.to_i..time.to_i - (week - 1).weeks.to_i)
        .count
    end
    weeks
  end

  def self.contribution_graph_making(span = 52, time = Time.now)   
    weeks = {}
    week = span
    count = 0;
    while week >= 1
        #initialising month variable with the month of the starting day 
        #of the week
        month = (time - (week*7 - 1).days).strftime('%m')
        #loop for finding the maximum occurence of a month name in that week
        #For eg. If this week has 3 days falling in March and 4 days falling
        #in April, then we would give this week name as April and vice-versa
        for i in 0..6 do
          currMonth = (time - (week*7 - i).days).strftime('%m')
          if month == 0
              month = currMonth
          elsif month != currMonth
              if i <= 4
                  month = currMonth
              end
          end
        end
        month = month.to_i
        #Now fetching comments per week
        currWeek = Comment.select(:timestamp)
                        .where(timestamp: time.to_i - week.weeks.to_i..time.to_i - (week - 1).weeks.to_i)
                        .count
        weeks[count] = [month, currWeek]
        count += 1
        week -= 1
    end
    weeks
  end

  def id
    cid
  end

  def created_at
    Time.at(timestamp)
  end

  def body
    finder = comment.gsub(Callouts.const_get(:FINDER), Callouts.const_get(:PRETTYLINKMD))
    finder = finder.gsub(Callouts.const_get(:HASHTAGNUMBER), Callouts.const_get(:NODELINKMD)) 
    finder = finder.gsub(Callouts.const_get(:HASHTAG), Callouts.const_get(:HASHLINKMD))  
    ApplicationController.helpers.emojify(finder)
  end

  def body_markdown
    RDiscount.new(body, :autolink).to_html
  end

  def icon
    "<i class='icon-comment'></i>"
  end

  def type
    'comment'
  end

  def tags
    []
  end

  def next_thread
    (thread.split('/').first.to_i(16) + 1).to_s(16).rjust(2, '0') + '/'
  end

  def parent
    if aid == 0
      node
    else
      return answer.node unless answer.nil?
    end
  end

  # users who are involved in this comment thread
  def thread_participants; end

  def mentioned_users
    usernames = comment.scan(Callouts.const_get(:FINDER))
    User.where(username: usernames.map { |m| m[1] }).distinct
  end

  def followers_of_mentioned_tags
    tagnames = comment.scan(Callouts.const_get(:HASHTAG))
    tagnames.map { |tagname| Tag.followers(tagname[1]) }.flatten.uniq
  end

  def notify_callout_users
    # notify mentioned users
    mentioned_users.each do |user|
      CommentMailer.notify_callout(self, user).deliver_now if user.username != author.username
    end
  end

  def notify_tag_followers(already_mailed_uids = [])
    # notify users who follow the tags mentioned in the comment
    followers_of_mentioned_tags.each do |user|
      CommentMailer.notify_tag_followers(self, user).deliver_now unless already_mailed_uids.include?(user.uid)
    end
  end

  def notify_users(uids, current_user)
    DrupalUser.where('uid IN (?)', uids).each do |user|
      if user.uid != current_user.uid
        CommentMailer.notify(user.user, self).deliver_now
      end
    end
  end

  # email all users in this thread
  # plus all who've starred it
  def notify(current_user)
    if parent.uid != current_user.uid
      CommentMailer.notify_note_author(parent.author, self).deliver_now
    end

    notify_callout_users

    # notify other commenters, revisers, and likers, but not those already @called out
    already = mentioned_users.collect(&:uid) + [parent.uid]
    uids = uids_to_notify - already

    notify_users(uids, current_user)
    notify_tag_followers(already + uids)
  end

  def answer_comment_notify(current_user)
    # notify answer author
    if answer.uid != current_user.uid
      CommentMailer.notify_answer_author(answer.author, self).deliver_now
    end

    notify_callout_users

    already = mentioned_users.collect(&:uid) + [answer.uid]
    uids = []
    # notify other answer commenter and users who liked the answer
    # except mentioned users and answer author
    (answer.comments.collect(&:uid) + answer.likers.collect(&:uid)).uniq.each do |u|
      uids << u unless already.include?(u)
    end

    notify_users(uids, current_user)
    notify_tag_followers(already + uids)
  end

  def spam
    self.status = 0
    save
    self
  end

  def publish
    self.status = 1
    save
    self
  end

end
