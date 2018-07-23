class SyncAnsweredQuestion < ActiveRecord::Migration[5.1]
  def up
    Answer.where(accepted: true).each do |a|
      node = a.node
      author = a.author
      node.add_tag('answered', author) unless node.nil?
    end    
  end

  def down
  end
end
