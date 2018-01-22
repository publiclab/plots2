class SyncAnsweredQuestion < ActiveRecord::Migration
  def up
    Answer.where(accepted: true).each do |a|
			node = a.node
			author = a.author
			node.add_tag('answered',author)
		end    
  end

  def down
  end
end
