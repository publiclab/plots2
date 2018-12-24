class RelationshipMailer < ApplicationMailer
	helper :application
  include ApplicationHelper
	default from: "notifications@#{ActionMailer::Base.default_url_options[:host]}"

	def notify_the_user_who_is_followed(followed_user,user_who_started_following)
		subject = "[PublicLab] #{user_who_started_following.username} started following you" 
		@followed_user = followed_user
		@footer = feature('email-footer')
		mail(to: @followed_user.email, subject: subject)
	end 
end
