class Comment < ActiveRecord::Base
  include CommentsShared # common methods for comment-like models

  attr_accessible :pid, :nid, :uid, :aid,
    :subject, :hostname, :comment,
    :status, :format, :thread, :timestamp

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

  def self.comment_monthly_tallies(span = 12, time = Time.now)
      months = {}
      year = Date.today.strftime('%Y').to_i-1
      currMonth = Date.today.strftime('%m').to_i
      (1..span).each do |month| 
          monthIndex = currMonth + month
          currYear = year
          if( monthIndex > 12)
              monthIndex = monthIndex % 12
              currYear = year+1
          end
          from = Date.new(currYear, monthIndex, 1).to_time.in_time_zone(0).to_i
          if(monthIndex == 12)
            toMonth=1
            toYear=currYear+1
          else
            toMonth=monthIndex+1
            toYear=currYear
          end
          to = Date.new(toYear, toMonth, 1).to_time.in_time_zone(0).to_i
          months[monthIndex] = Comment.select(:timestamp)
                                      .where(timestamp: from .. to)
                                      .count
      end
      months
  end 

	def self.contribution_graph_making(span= 52, time= Time.now)   
    weeks = {}
    week = 52
    count = 0;
    while week >= 0
       month = 0 
      for i in 0..6 do
          currMonth = (time - (week*7-i).days).strftime('%m')
          if month == 0
              month = currMonth
          elsif month != currMonth
              if i <= 4
                  month = currMonth
              end
          end
      end
      month=month.to_i
      currWeek = Comment.select(:timestamp)
                     	.where(timestamp: time.to_i - week.weeks.to_i..time.to_i - (week - 1).weeks.to_i)
                        .count
      weeks[count] = [month, currWeek]
      count+=1
      week-=1
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
    User.where(username: usernames.map { |m| m[1] }).uniq
  end

  def followers_of_mentioned_tags
    tagnames = comment.scan(Callouts.const_get(:HASHTAG))
    tagnames.map { |tagname| Tag.followers(tagname[1]) }.flatten.uniq
  end

  def notify_callout_users
    # notify mentioned users
    mentioned_users.each do |user|
      CommentMailer.notify_callout(self, user) if user.username != author.username
    end
  end

  def notify_tag_followers(already_mailed_uids = [])
    # notify users who follow the tags mentioned in the comment
    followers_of_mentioned_tags.each do |user|
      CommentMailer.notify_tag_followers(self, user) unless already_mailed_uids.include?(user.uid)
    end
  end

  def notify_users(uids, current_user)
    DrupalUser.where('uid IN (?)', uids).each do |user|
      if user.uid != current_user.uid
        CommentMailer.notify(user.user, self).deliver
      end
    end
  end

  # email all users in this thread
  # plus all who've starred it
  def notify(current_user)
    if parent.uid != current_user.uid
      CommentMailer.notify_note_author(parent.author, self).deliver
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
      CommentMailer.notify_answer_author(answer.author, self).deliver
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
