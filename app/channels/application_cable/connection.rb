module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    def connect
      self.current_user = find_verified_user
    end

    def find_verified_user
      unless cookies.signed['user_token'].nil?
        user = User.where(persistence_token: cookies.signed['user_token'])
        if user.any?
          return user.first
        else
          return nil
        end
      end
    end
  end
end
