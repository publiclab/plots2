class AddNotificationUserTags < ActiveRecord::Migration[5.2]
  def change
    User.all.each do |user|
      if !UserTag.where(value: 'notifications:all', uid: uid).any?
        ut = UserTag.new
        ut.value = "notifications:all"
        ut.uid = user.id
        ut.save!
      end
    end
  end
end
