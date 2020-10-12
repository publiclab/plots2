class DigestMailJob
  include Sidekiq::Worker
  # This is a separate job for sending digest mails.This job could be enqueued for executing task asynchronously.
  def perform(frequency)
    if frequency == 0 # DIGEST_DAILY
      tag = 'digest:daily'
    elsif frequency == 1 # DIGEST_WEEKLY
      tag = 'digest:weekly'
    end
    users = User.includes(:user_tags)
      .references(:user_tags)
      .where('user_tags.value=?', tag)
      .all
    users.each(&:send_digest_email)
  end
end
