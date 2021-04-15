class DigestSpamJob
  include Sidekiq::Worker
  def perform(frequency_digest)
    if frequency_digest.zero?
      tag_digest = 'digest:daily:spam'
    elsif frequency_digest == 1
      tag_digest = 'digest:weekly:spam'
    end
    users = User.where(role: %w(moderator admin))
              .includes(:user_tags)
              .where('user_tags.value=?', tag_digest)
              .references(:user_tags)
    users.each(&:send_digest_email_spam)
  end
end
