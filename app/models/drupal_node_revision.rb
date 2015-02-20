class DrupalNodeRevision < ActiveRecord::Base
  attr_accessible :title, :body, :nid, :uid, :teaser, :log, :timestamp, :format
  self.table_name = 'node_revisions'
  self.primary_key = 'vid'

  belongs_to :drupal_node, :foreign_key => 'nid', :dependent => :destroy, :counter_cache => true
  has_one :drupal_users, :foreign_key => 'uid'

  validates :title, 
    :presence => :true, 
    :length => { :minimum => 2, :maximum => 100 },
    :format => {:with => /[A-Z][\w\-_]*/i, :message => "can only include letters, numbers, and dashes"}
  validates :body, :presence => :true
  validates :uid, :presence => :true
  validates :nid, :presence => :true

  before_save :inline_tags

  # search for inline special tags such as [question:foo]
  def inline_tags
    self.body.scan(/\[question(:[\w-]+)\]/).each do |match|
      self.parent.add_tag("prompt"+match.first,self.author)
    end
  end

  def created_at
    Time.at(self.timestamp)
  end

  def author
    DrupalUsers.find_by_uid self.uid
  end

  def parent
    self.drupal_node
  end

  # filtered version of node content
  def render_body
    body = self.body || ""
    body = RDiscount.new(body, :generate_toc)
    body = body.to_html
    body = body.gsub(Callouts.const_get(:FINDER), Callouts.const_get(:PRETTYLINKHTML))
    body = body.gsub('[edit]','<p class="well" style="padding:6px;"><a class="btn btn-primary" href="'+self.parent.edit_path+'"><i class="icon icon-white icon-pencil"></i> Edit this page</a> to help complete it!</p>')
    body = body.gsub(/\[question:([\w-]+)\]/,'<p class="well" style="padding:6px;"><a style="margin-bottom:6px;" class="btn btn-primary" href="/post?tags=question:\\1&template=question"><i class="icon icon-white icon-question-sign"></i> Ask a question about <b>\\1</b></a> or <a style="margin-bottom:6px;" class="btn" target="_blank" href="/subscribe/tag/question:\\1">Sign up to answer questions on this topic</a></p>')
    body
  end

end
