class AddFirstTagPoster < ActiveRecord::Migration[5.2]
  def find_and_update
    User.joins(:node).where('node.status = ?', 1).each do |user|
      if user.nodes.present?
        node = user.nodes.first
        node.add_tag('first-time-post', user)
      end
    end
  end

  def up
    find_and_update
  end
end
