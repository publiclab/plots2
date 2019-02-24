namespace :first_timer_tag do
  desc 'Script that goes back and checks if the first post of a user has
  first-timer poster if not, it adds it'

  task add_poster_tag:  :environment do
    p 'Finding first timer tag'
    find_first_time_tag
    p 'Updating first timer tag to all users first posts...'
    find_and_update
    p 'Done...'
  end
end

def find_and_update
  arr = []
  User.all.each do |user|
    arr.push(user.nodes.first) unless user.nodes.first.nil?
  end
  arr.each do |node|
    if node.tags.find_by(name: "first-time-post").nil?
      node.tags.push(Tag.find_by(name: "first-time-post"))
    end
  end
end

def find_first_time_tag
  Tag.find_or_create_by(name: "first-time-post") do |tag|
    tag.description =  "This is the first post posted by this user"
  end
end
