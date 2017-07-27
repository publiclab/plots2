
# will only work in Ruby 1.9+:
class String
   def multibyte?
     chars.count < bytes.count
   end
end

class RecoverBiosTokensStatuses < ActiveRecord::Migration
  def up
      DrupalUsers.find(:all).each do |u|
        unless u.name.multibyte?
          user = u.user
          if user
            user.status = u.status unless u.nil?
            user.bio = DrupalProfileValue.find_by_uid(user.id, conditions: { fid: 7 }) || ''
            user.token = SecureRandom.uuid
            user.save({})
          end
        end
      end
  end

  def down
      raise ActiveRecord::IrreversibleMigration
  end
end
