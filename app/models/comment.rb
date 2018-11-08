class Comment < ApplicationRecord
  include CommentsShared # common methods for comment-like models

  belongs_to :node, foreign_key: 'nid', touch: true, counter_cache: true
  # dependent: :destroy, counter_cache: true
  belongs_to :drupal_user, foreign_key: 'uid'
  belongs_to :answer, foreign_key: 'aid'
  has_many :likes, :as => :likeable

  validates :comment, presence: true

  self.table_name = 'comments'
  self.primary_key = 'cid'

  COMMENT_FILTER = "<!-- @@$$%% Trimmed Content @@$$%% -->".freeze

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
    count = 0
    while week >= 1
      # initialising month variable with the month of the starting day
      # of the week
      month = (time - (week * 7 - 1).days).strftime('%m')

      month = month.to_i
      # Now fetching comments per week
      current_week = Comment.select(:timestamp)
        .where(timestamp: time.to_i - week.weeks.to_i..time.to_i - (week - 1).weeks.to_i)
        .count
      weeks[count] = [month, current_week]
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
    if parent.uid != current_user.uid && !UserTag.exists?(parent.uid, 'notify-comment-direct:false')
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

  def liked_by(user_id)
    likes.where(user_id: user_id).count > 0
  end

  def likers
    User.where(id: likes.pluck(:user_id))
  end

  def emoji_likes
    likes.group(:emoji_type).count
  end

  def user_reactions_map
    likes_map = likes.where.not(emoji_type: nil).includes(:user).group_by(&:emoji_type)
    user_like_map = {}
    likes_map.each do |reaction, likes|
      users = []
      likes.each do |like|
        users << like.user.name
      end

      emoji_type = reaction.underscore.humanize.downcase
      users_string = (users.length > 1 ? users[0..-2].join(", ") + " and " + users[-1] : users[0]) + " reacted with " + emoji_type + " emoji"
      user_like_map[reaction] = users_string
    end
    user_like_map
  end

  def self.receive_mail(mail)
    user = User.where(email: mail.from.first).first
    if user
      node_id = mail.subject[/#([\d]+)/, 1] # This tooks out the node ID from the subject line
      if node_id.nil?
        answer_id = mail.subject[/#a([\d]+)/, 1] # This tooks out the answer ID from the subject line
        unless answer_id.nil?
          add_answer_comment(mail, answer_id, user)
        end
      else
        add_comment(mail, node_id, user)
      end
    end
  end

  def self.add_answer_comment(mail, answer_id, user)
    answer = Answer.where(id: answer_id).first
    if answer
      mail_doc = Nokogiri::HTML(mail.html_part.body.decoded) # To parse the mail to extract comment content and reply content
      domain = get_domain mail.from.first
      content = if domain == "gmail"
                  gmail_parsed_mail mail_doc
                elsif domain == "yahoo"
                  yahoo_parsed_mail mail_doc
                elsif gmail_quote_present?(mail_doc)
                  gmail_parsed_mail mail_doc
                else
                  {
                    "comment_content" => mail_doc,
                    "extra_content" => nil
                  }
                end
      if content["extra_content"].nil?
        comment_content_markdown = ReverseMarkdown.convert content["comment_content"]
      else
        extra_content_markdown = ReverseMarkdown.convert content["extra_content"]
        comment_content_markdown = ReverseMarkdown.convert content["comment_content"]
        comment_content_markdown = comment_content_markdown + COMMENT_FILTER + extra_content_markdown
      end
      message_id = mail.message_id
      comment = Comment.new(uid: user.uid,
        aid: answer_id,
        comment: comment_content_markdown,
        comment_via: 1,
        message_id: message_id,
        timestamp: Time.now.to_i)
      if comment.save
        comment.answer_comment_notify(user)
      end
    end
  end

  def self.add_comment(mail, node_id, user)
    node = Node.where(nid: node_id).first
    if node
      mail_doc = Nokogiri::HTML(mail.html_part.body.decoded) # To parse the mail to extract comment content and reply content
      domain = get_domain mail.from.first
      content = if domain == "gmail"
                  gmail_parsed_mail mail_doc
                elsif domain == "yahoo"
                  yahoo_parsed_mail mail_doc
                elsif gmail_quote_present?(mail_doc)
                  gmail_parsed_mail mail_doc
                else
                  {
                    "comment_content" => mail_doc,
                    "extra_content" => nil
                  }
                end
      if content["extra_content"].nil?
        comment_content_markdown = ReverseMarkdown.convert content["comment_content"]
      else
        extra_content_markdown = ReverseMarkdown.convert content["extra_content"]
        comment_content_markdown = ReverseMarkdown.convert content["comment_content"]
        comment_content_markdown = comment_content_markdown + COMMENT_FILTER + extra_content_markdown
      end
      message_id = mail.message_id
      comment = node.add_comment(uid: user.uid, body: comment_content_markdown, comment_via: 1, message_id: message_id)
      comment.notify user
    end
  end

  def self.gmail_quote_present?(mail_doc)
    mail_doc.css(".gmail_quote").any?
  end

  def self.get_domain(email)
    domain = email[/(?<=@)[^.]+(?=\.)/, 0]
  end

  def self.yahoo_parsed_mail(mail_doc)
    if mail_doc.css(".yahoo_quoted")
      extra_content = mail_doc.css(".yahoo_quoted")[0]
      mail_doc.css(".yahoo_quoted")[0].remove
      comment_content = mail_doc
    else
      comment_content = mail_doc
      extra_content = nil
    end

    {
      "comment_content" => comment_content,
      "extra_content" => extra_content
    }
  end

  def self.gmail_parsed_mail(mail_doc)
    if mail_doc.css(".gmail_quote").any?
      extra_content = mail_doc.css(".gmail_quote")[0]
      mail_doc.css(".gmail_quote")[0].remove
      comment_content = mail_doc
    else
      comment_content = mail_doc
      extra_content = nil
    end

    {
      "comment_content" => comment_content,
      "extra_content" => extra_content
    }
  end

  def trimmed_content?
    comment.include?(COMMENT_FILTER)
  end

  def parse_quoted_text
    match = body.match(/(.+)(On .+<.+@.+> wrote:)(.+)/m)
    if match.nil?
      false
    else
      {
        body: match[1], # the new message text
        boundary: match[2], # quote delimeter, i.e. "On Tuesday, 3 July 2018, 11:20:57 PM IST, RP <rp@email.com> wrote:"
        quote: match[3] # quoted text from prior email chain
      }
    end
  end

  def scrub_quoted_text
    parse_quoted_text[:body]
  end

  def render_body
    body = RDiscount.new(
      title_suggestion(self),
      :autolink
    ).to_html
    # if it has quoted email text that wasn't caught by the yahoo and gmail filters,
    # manually insert the comment filter delimeter:
    parsed = parse_quoted_text
    if !trimmed_content? && parsed != false
      body = parsed[:body] + COMMENT_FILTER + parsed[:boundary] + parsed[:quote]
    end
    body
  end
end
