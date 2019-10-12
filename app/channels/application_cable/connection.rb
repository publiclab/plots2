module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    def connect
      self.current_user = find_verified_user
    end

    def find_verified_user
      return if cookies.signed['user_token'].nil?

      user = User.where(persistence_token: cookies.signed['user_token'])

      return user.first if user.any?
    end
  end
end
