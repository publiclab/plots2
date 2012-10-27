class DrupalUsers < ActiveRecord::Base
  # attr_accessible :title, :body
  self.table_name = 'users'
  self.primary_key = 'fid'

  has_many :drupal_node, :foreign_key => 'uid'
  has_many :drupal_profile_values, :foreign_key => 'uid'
  has_many :drupal_profile_, :through => :drupal_node_tag

  def notes
    DrupalNode.find_all_by_uid self.uid
  end

  # accepts array of tag names (strings)
  def notes_for_tags(tagnames)
    all_nodes = DrupalNode.find(:all,:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => self.uid})
    node_ids = []
    all_nodes.each do |node|
      node.tags.each do |tag|
        tagnames.each do |tagname|
          node_ids << node.nid if tag.name == tagname
        end
      end
    end
    DrupalNode.find(node_ids.uniq, :order => "nid DESC")
  end

  def created_at
    Time.at(self.created)
  end

  def profile_values
    self.drupal_profile_values
  end

end
