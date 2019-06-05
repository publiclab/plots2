class AnswerMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "notifications@#{ActionMailer::Base.default_url_options[:host]}"
end
