class SyncUserStatusWithDrupalUserStatus < ActiveRecord::Migration[5.1]
  def up
    DrupalUser.all.each do |du|
      user = du.user
      if user
        user.status = du.status
        user.save({})
      end
    end
  end

  def down
  end
end
