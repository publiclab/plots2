
# will only work in Ruby 1.9+:
class String
   def multibyte?
     chars.count < bytes.count
   end
end

class RecoverBiosTokensStatuses < ActiveRecord::Migration
  def up
      DrupalUsers.where('status != 0').each do |u|
        unless u.name.multibyte?
          user = u.user
          if user
            user.status = u.status unless u.nil?
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
