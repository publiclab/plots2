class DigestMailJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    users = User.includes(:user_tags).references(:user_tags).where('user_tags.value=?','digest:weekly').all
  	users.each do |u|
  		u.send_digest_email	
  	end
  end
end
