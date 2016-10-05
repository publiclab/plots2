# rake test:all
namespace :test do
  desc "Run rails and jasmine tests"
  task :all do
    puts "Running Rails tests"
    Rake::Task["test"].execute
    puts "Running Solr tests"
    Rake::Task["test:solr"].execute
    puts "Running jasmine tests headlessly"
    Rake::Task["spec:javascript"].execute
  end
  task :solr do
    puts "Running Solr-dependent tests"
    # overwrite "diabled" in test for sunspot.yml
    require 'yaml'
    sunspot = YAML::load_file "config/sunspot.yml"
    sunspot['test']['disabled'] = false
    File.open("config/sunspot.yml", "w") do |file|
      file.write sunspot.to_yaml
    end
    puts "turning on solr dependence at config/sunspot.yml"
    puts sunspot.to_yaml
    puts `rake sunspot:solr:start RAILS_ENV=test`
    sleep(40)
    puts `rake test TEST=test/solr/searches_controller_test.rb`
    puts `rake sunspot:solr:stop RAILS_ENV=test`
    # restore "diabled" to true in test for sunspot.yml
    sunspot['test']['disabled'] = true
    File.open("config/sunspot.yml", "w") do |file|
      file.write sunspot.to_yaml
    end
  end
end
