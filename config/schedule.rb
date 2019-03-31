# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Work around whenever Gem issue (see https://github.com/publiclab/plots2/issues/3404)
env :PATH, ENV['PATH']
env :GEM_HOME, ENV['GEM_HOME']
env :SECRET_KEY_BASE, ENV['SECRET_KEY_BASE']
env :REDIS_URL, ENV['REDIS_URL']

# Cron Job log file

set :bundle_command, 'bundle exec'
job_type :runner,  "cd :path && :bundle_command rails runner -e :environment ':task' :output"

ENV.each { |k, v| env(k, v) }

set :output, "#{Dir.pwd}/public/cron_log.log"

# To simply print date into the log file for checking if cron job is working properly
every 1.minutes do
  command "date -u" #This will print utc time every 1 min in log/cron_log.log file
end

every 10.minutes do
  runner "Comment.receive_tweet"
end


every 1.day do
  runner "DigestMailJob.perform_async(0)"
end

every 1.week do
  runner "DigestMailJob.perform_async(1)"
end
