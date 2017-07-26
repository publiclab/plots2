class TokenBioFixes < ActiveRecord::Migration
  def up
    DrupalUsers.where('status != 0').each do |u|
      unless u.name.multibyte? # exclude non-latin names
        user = u.user
        if user and defined? :u.status then
          user.status = u.status
          profile = DrupalProfileValue.find_by_uid(user.id, conditions: { fid: 7 })
          user.bio = profile.value || '' if profile
          user.token = SecureRandom.uuid
          user.save({})
        end
      end
    end
  end

  def down
  end
end
