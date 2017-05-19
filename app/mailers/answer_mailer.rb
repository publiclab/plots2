class AnswerMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "do-not-reply@#{ActionMailer::Base.default_url_options[:host]}"

  def notify_question_author(user, answer)
    subject = '[PublicLab] New answer to Question: ' + answer.node.title
    @user = user
    @answer = answer
    @footer = feature('email-footer')
    mail(to: @user.email, subject: subject)
  end

  def notify_answer_likers_author(user, answer)
    subject = '[PublicLab] New answer to Question: ' + answer.node.title
    @user = user
    @answer = answer
    @footer = feature('email-footer')
    mail(to: @user.email, subject: subject)
  end

  def notify_answer_accept(user, answer)
    @user = user
    @answer = answer
    @footer = feature('email-footer')
    mail(to: @user.email, subject: '[PublicLab] Your answer has been accepted')
  end

  def notify_answer_like(user, answer)
    subject = "[PublicLab] #{user.username} liked your answer to: " + answer.node.title
    @user = user
    @answer = answer
    @footer = feature('email-footer')
    mail(to: @answer.author.email, subject: subject)
  end
end
