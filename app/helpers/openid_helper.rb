# frozen_string_literal: true

module OpenidHelper
  def url_for_user
    '/profile/' + current_user.username
  end
end
