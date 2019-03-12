class Comment < ApplicationRecord
  include CommentsShared

  belongs_to :node, foreign_key: 'nid', touch: true, counter_cache: true
  belongs_to :user, foreign_key: 'uid'
  belongs_to :answer, foreign_key: 'aid'
  has_many :likes, as: :likeable

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

  def self.comment_weekly_tallies(span = 52, time = Time.current)
    weeks = {}
    (0..span).each do |week|
      weeks[span - week] = Comment.select(:timestamp)
        .where(timestamp: time.to_i - week.weeks.to_i..time.to_i - (week - 1).weeks.to_i)
        .count
    end
    weeks
  end

  def self.contribution_graph_making(start_time = 1.month.ago, end_time = Time.current)
    date_hash = {}
    (start_time.to_date..end_time.to_date).each do |date|
      daily_comments = Comment.select(:timestamp)
                         .where(timestamp: (date.beginning_of_week.to_time.to_i)..(date.end_of_week.to_time.to_i))
                         .count
      date_hash[date.beginning_of_week.to_time.to_i.to_f * 1000] = daily_comments
    end
    date_hash
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
    aid.zero? ? node : answer&.node
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
    User.where('id IN (?)', uids).find_each do |user|
      if user.uid != current_user.uid
        CommentMailer.notify(user, self).deliver_now
      end
    end
  end

  # email all users in this thread
  # plus all who've starred it
  def notify(current_user)
    if status == 4
      AdminMailer.notify_comment_moderators(self).deliver_now
    else
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
                elsif domain == "outlook"
                  outlook_parsed_mail mail_doc
                elsif gmail_quote_present?(mail_doc)
                  gmail_parsed_mail mail_doc
                else
                  {
                    comment_content: mail_doc,
                    extra_content: nil
                  }
                end
      if content[:extra_content].nil?
        comment_content_markdown = ReverseMarkdown.convert content[:comment_content]
      else
        extra_content_markdown = ReverseMarkdown.convert content[:extra_content]
        comment_content_markdown = ReverseMarkdown.convert content[:comment_content]
        comment_content_markdown = comment_content_markdown + COMMENT_FILTER + extra_content_markdown
      end
      message_id = mail.message_id
      comment = Comment.new(uid: user.uid,
        aid: answer_id,
        comment: comment_content_markdown,
        comment_via: 1,
        message_id: message_id,
        timestamp: Time.current.to_i)
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
                elsif domain == "outlook"
                  outlook_parsed_mail mail_doc
                elsif gmail_quote_present?(mail_doc)
                  gmail_parsed_mail mail_doc
                else
                  {
                    comment_content: mail_doc,
                    extra_content: nil
                  }
                end
      if content[:extra_content].nil?
        comment_content_markdown = ReverseMarkdown.convert content[:comment_content]
      else
        extra_content_markdown = ReverseMarkdown.convert content[:extra_content]
        comment_content_markdown = ReverseMarkdown.convert content[:comment_content]
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
    email[/(?<=@)[^.]+(?=\.)/, 0]
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
      comment_content: comment_content,
      extra_content: extra_content
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
      comment_content: comment_content,
      extra_content: extra_content
    }
  end

  def self.outlook_parsed_mail(mail_doc)
    separator = mail_doc.inner_html.match(/(.+)(<div id="appendonsend"><\/div>)(.+)/m)
    if separator.nil?
      comment_content = mail_doc
      extra_content = nil
    else
      body_message = separator[1].match(/(.+)(<body dir="ltr">)(.+)/m)
      comment_content = Nokogiri::HTML(body_message[3])
      trimmed_message = separator[3].match(/(.+)(<\/body>)(.+)/m)
      extra_content = Nokogiri::HTML(trimmed_message[1])
    end

    {
      comment_content: comment_content,
      extra_content: extra_content
    }
  end

  def trimmed_content?
    comment.include?(COMMENT_FILTER)
  end

  def self.receive_tweet
    comments = Comment.where.not(tweet_id: nil)
    if comments.any?
      receive_tweet_using_since comments
    else
      receive_tweet_without_using_since
    end
  end

  def self.receive_tweet_using_since(comments)
    comment = comments.last
    since_id = comment.tweet_id
    tweets = Client.search(ENV["TWEET_SEARCH"], since_id: since_id).collect do |tweet|
      tweet
    end
    tweets.each do |tweet|
      puts tweet.text
    end
    tweets = tweets.reverse
    check_and_add_tweets tweets
  end

  def self.receive_tweet_without_using_since
    tweets = Client.search(ENV["TWEET_SEARCH"]).collect do |tweet|
      tweet
    end
    tweets = tweets.reverse
    check_and_add_tweets tweets
    tweets.each do |tweet|
      puts tweet.text
    end
  end

  def self.check_and_add_tweets(tweets)
    tweets.each do |tweet|
      next unless tweet.reply?

      in_reply_to_tweet_id = tweet.in_reply_to_tweet_id
      next unless in_reply_to_tweet_id.class == Integer

      parent_tweet = Client.status(in_reply_to_tweet_id, tweet_mode: "extended")
      parent_tweet_full_text = parent_tweet.attrs[:text] || parent_tweet.attrs[:full_text]
      urls = URI.extract(parent_tweet_full_text)
      node = get_node_from_urls_present(urls)
      next if node.nil?

      twitter_user_name = tweet.user.screen_name
      tweet_email = find_email(twitter_user_name)
      users = User.where(email: tweet_email)
      next unless users.any?

      user = users.first
      replied_tweet_text = tweet.text
      if tweet.truncated?
        replied_tweet = Client.status(tweet.id, tweet_mode: "extended")
        replied_tweet_text = replied_tweet.attrs[:text] || replied_tweet.attrs[:full_text]
      end
      replied_tweet_text = replied_tweet_text.gsub(/@(\S+)/) { |m| "[#{m}](https://twitter.com/#{m})" }
      replied_tweet_text = replied_tweet_text.delete('@')
      comment = node.add_comment(uid: user.uid, body: replied_tweet_text, comment_via: 2, tweet_id: tweet.id)
      comment.notify user
    end
  end

  def self.get_node_from_urls_present(urls)
    urls.each do |url|
      next unless url.include? "https://"

      if url.last == "."
        url = url[0...url.length - 1]
      end
      response = Net::HTTP.get_response(URI(url))
      redirected_url = response['location']
      next unless !redirected_url.nil? && redirected_url.include?(ENV["WEBSITE_HOST_PATTERN"])

      node_id = redirected_url.split("/")[-1]
      next if node_id.nil?

      node = Node.where(nid: node_id.to_i)
      if node.any?
        return node.first
      end
    end
    nil
  end

  def self.find_email(twitter_user_name)
    UserTag.where('value LIKE (?)', 'oauth:twitter%').where.not(data: nil).each do |user_tag|
      data = user_tag["data"]
      if !data.nil? && !data["info"].nil? && !data["info"]["nickname"].nil? && data["info"]["nickname"].to_s == twitter_user_name
        return data["info"]["email"]
      end
    end
  end

  def parse_quoted_text
    if regex_match = body.match(/(.+)(On .+<.+@.+> wrote:)(.+)/m)
      {
        body: regex_match[1],     # The new message text
        boundary: regex_match[2], # Quote delimeter, i.e. "On Tuesday, 3 July 2018, 11:20:57 PM IST, RP <rp@email.com> wrote:"
        quote: regex_match[3]     # Quoted text from prior email chain
      }
    else
      {}
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
    if !trimmed_content? && parsed.present?
      body = parsed[:body] + COMMENT_FILTER + parsed[:boundary] + parsed[:quote]
    end
    body
  end
end
