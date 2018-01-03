module StatsHelper
	def contributor_count(start_time,end_time)
		answers = Answer.where(created_at: start_time..end_time).pluck(:uid)
		questions = Node.questions.where(status: 1, created: start_time.to_i..end_time.to_i).pluck(:uid)
	  comments = Comment.where(timestamp: start_time.to_i..end_time.to_i).pluck(:uid)
	  contributors = uniq_users(answers+questions+comments)
	  contributors
	end
	
	private

	def uniq_users users
		users.compact.uniq.length
	end
end