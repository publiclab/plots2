class AddUserForOrphanedDrupalUser < ActiveRecord::Migration
  def change
    DrupalUser.all.each do |du|
      if du.user.nil?
        du.migrate
      end
    end
  end
end
