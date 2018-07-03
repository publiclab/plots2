class DigestMailJob
  include Sidekiq::Worker
  # This is a separate job for sending digest mails.This job could be enqueued for executing task asynchronously.
  def perform
    users = User.includes(:user_tags).references(:user_tags).where('user_tags.value=?', 'digest:weekly').all
    users.each(&:send_digest_email)
  end
end
