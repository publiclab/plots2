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

# Cron Job log file
set :output, "#{Dir.pwd}/public/cron_log.log"

# To simply print date into the log file for checking if cron job is working properly
every 1.minutes do
	puts Dir.pwd
	command "date -u" #This will print utc time every 1 min in log/cron_log.log file
end
