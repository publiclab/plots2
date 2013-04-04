class TagSelection < ActiveRecord::Base
  attr_accessible :following
  belongs_to :user
  belongs_to :drupal_tag, :foreign_key => 'tid'

  def tag
    self.drupal_tag
  end

end
