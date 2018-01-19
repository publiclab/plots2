class SyncUserStatusAndAnsweredQuestion < ActiveRecord::Migration
  def up
    DrupalUser.all do |du|
    	user = du.user
    	user.status = du.status
    	user.save({})
    end

		Answer.where(accepted: true).each do |a|
			node = a.node
			author = a.author
			node.add_tag('answered',author)
		end    
  end

  def down
  end
end
