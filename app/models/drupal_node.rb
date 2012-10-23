class DrupalNode < ActiveRecord::Base
  # attr_accessible :title, :body
  set_table_name :node
  has_one :drupal_node_revision, :foreign_key => 'nid'

  self.primary_key = 'nid'
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name == 'changed'
      return true if method_name == 'changed?'
      super
    end
  end

  def self.inheritance_column
    "rails_type"
  end

  def created_at
    Time.at(self.drupal_node_revision.timestamp)
  end

end
