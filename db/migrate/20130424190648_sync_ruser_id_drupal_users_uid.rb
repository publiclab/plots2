class SyncRuserIdDrupalUsersUid < ActiveRecord::Migration[5.1]
  def up
    User.find(:all).each do |user|
      user.id = user.uid
      user.save({})
    end
  end

  def down
  end
end
