class Revision < ApplicationRecord
  self.table_name = 'node_revisions'
  self.primary_key = 'vid'

  belongs_to :node, foreign_key: 'nid', counter_cache: :drupal_node_revisions_count
  has_one :user, foreign_key: 'uid'
  has_many :node_tag, foreign_key: 'nid'
  has_many :tag, through: :node_tag

  validates :title,
    presence: true,
    length: { minimum: 2 },
    format: { with: /[A-Z][\w\-_]*/i, message: 'can only include letters, numbers, and dashes' }
  validates :body, presence: true
  validates :uid, presence: true
  validates :nid, presence: true

  before_save :inline_tags
  after_save :inline_hashtags
  before_create :setup

  scope :published, -> { where(status: 1) }
  scope :past_week, -> { where("timestamp > ?", 7.days.ago) }
  scope :past_month, -> { where("timestamp > ?", 1.month.ago) }
  scope :past_year, -> { where("timestamp > ?", 1.year.ago) }

  def setup
    self.teaser = ''
    self.log = ''
    self.timestamp = DateTime.now.to_i
    self.format = 1
  end

  def publish
    self.status = 1
    save
    self
  end

  def spam
    self.status = 0
    save
    self
  end

  # search for inline special tags such as [question:foo]
  def inline_tags
    body.scan(/\[question(:[\w-]+)\]/).each do |match|
      parent.add_tag('prompt' + match.first, author)
    end
  end

  # search for inline hashtags(such as #hashtag) and create a new tag
  def inline_hashtags
    body.scan(Callouts.const_get(:HASHTAGWITHOUTNUMBER)).each do |match|
      parent.add_tag(match.last, author)
    end
  end

  def created_at
    Time.at(timestamp)
  end

  def updated_at
    Time.at(timestamp)
  end

  def path
    node.path
  end

  def author
    User.find_by(id: uid)
  end

  def parent
    node
  end

  def is_initial?
    parent.revision.count == 1
  end

  def previous
    parent.revision.order('timestamp DESC')
      .where('timestamp < ?', timestamp)
      .first
  end

  def next
    parent.revision.order('timestamp DESC')
      .where('timestamp > ?', timestamp)
      .last
  end

  # filtered version of node content
  def render_body
    body = self.body || ''
    body = RDiscount.new(body)
    body = body.to_html
    body = body.gsub(Callouts.const_get(:FINDER), Callouts.const_get(:PRETTYLINKHTML))
    body = body.gsub(Callouts.const_get(:HASHTAGNUMBER), Callouts.const_get(:NODELINKHTML))
    body = body.gsub(Callouts.const_get(:HASHTAG), Callouts.const_get(:HASHLINKHTML))
    body = body.gsub(/(\d+\. |\* )\K\[(x|X)\]/, %(<input type="checkbox" editable="false" checked="checked" />)).gsub(/(\d+\. |\* )\K\[ \]/, %(<input type="checkbox" editable="false" />))
    ApplicationController.helpers.emojify(body_extras(body)).to_s
  end

  # filtered version of node content, but without running Markdown
  def render_body_raw
    body = self.body || ''
    body = body.to_html
    body = body.gsub(Callouts.const_get(:FINDER), Callouts.const_get(:PRETTYLINKHTML))
    body = body.gsub(Callouts.const_get(:HASHTAGNUMBER), Callouts.const_get(:NODELINKHTML))
    body = body.gsub(Callouts.const_get(:HASHTAG), Callouts.const_get(:HASHLINKHTML))
    body = body.gsub(/(\d+\. |\* )\K\[(x|X)\]/, %(<input type="checkbox" editable="false" checked="checked" />)).gsub(/(\d+\. |\* )\K\[ \]/, %(<input type="checkbox" editable="false" />))
    insert_extras(body_extras(body))
  end

  # filtered version additionally appending http/https protocol to protocol-relative URLs like "/foo"
  # render_body plus making all relative links absolute
  def render_body_email(host = 'publiclab.org')
    body = render_body.gsub(/([\s|"|'|\[|\(])(\/\/)([\w]?\.?#{host})/, '\1https://\3')
    body = body.gsub("href='/", "href='https://#{host}/")
    body = body.gsub('href="/', 'href="https://' + host.to_s + '/')
    body = body.gsub("src='/", "src='https://#{host}/")
    body = body.gsub('src="/', 'src="https://' + host.to_s + '/')
    body
  end

  def body_preview(length = 100)
    newBody = body.gsub(/^#+.+/, '')
    newBody.truncate(length)
  end

  # some adaptations for the new rich editor
  def body_rich
    # turn ##Headers into ## Headers
    body.gsub(/(^|\n)(#+)([A-z]+)/, '\1\2 \3')
  end

  def body_raw
    body_extras(body)
  end

  def body_extras(content)
    # inline edit button adds a # if vid is absent showing a preview
    edit_path = vid ? parent.edit_path : '#'
    content = content.gsub('[edit]', '<p class="well" style="padding:6px;"><a class="btn btn-primary" href="' + edit_path + '"><i class="fa fa-white icon-pencil"></i> Edit this page</a> to help complete it!</p>')
    # inline question button
    content = content.gsub(/\[question:([\w-]+)\]/, '<p class="well" style="padding:6px;"><a style="margin-bottom:6px;" class="btn btn-primary" href="/post?tags=question:\\1&template=question"><i class="fa fa-white icon-question-sign"></i> Ask a question about <b>\\1</b></a> or <a style="margin-bottom:6px;" class="btn" target="_blank" href="/subscribe/tag/question:\\1">Sign up to answer questions on this topic</a></p>')
    # inline foldaway
    content = content.gsub(/\[fold\:(.+)\]/, '<p class="foldaway-link" data-title="\1"><i style="color:#666;padding-right:3px;" class="fa fa-expand-alt"></i> <a>\1 &raquo;</a></p><div class="foldaway" data-title="\1">')
    content = content.gsub('[unfold]', '</div>')
    content
  end

  def self.frequency(starting, ending)
    weeks = (ending.to_date - starting.to_date).to_i / 7.0
    Revision.select(:timestamp)
      .where(timestamp: starting.to_i..ending.to_i)
      .count / weeks
  end
end
