# rake test:all
namespace :test do
  desc "Run rails and jasmine tests"
  task :all do
    require 'coveralls/rake/task'
    Coveralls::RakeTask.new
    puts "Running Rails tests"
    Rake::Task["test"].execute
    puts "Running Solr-dependent tests"
    Rake::Task["test:solr"].execute
    puts "Running jasmine tests headlessly"
    Rake::Task["spec:javascript"].execute
    Rake::Task["coveralls:push"].execute
  end

  desc "Run rails and jasmine tests"
  task :javascript do
    puts "Running jasmine tests headlessly"
    Rake::Task["spec:javascript"].execute
  end

  desc "Start embedded Solr engine, turn off Solr 'disabled=true' config and run solr-specific tests"
  task :solr do
    require 'yaml'
    sunspot = YAML::load_file "config/sunspot.yml"
    # overwrite "disabled" to false in test for sunspot.yml
    sunspot['test']['disabled'] = false
    File.open("config/sunspot.yml", "w") do |file|
      file.write sunspot.to_yaml
    end
    puts "turning on solr dependence at config/sunspot.yml"
    # puts sunspot.to_yaml
    `rake sunspot:solr:start RAILS_ENV=test`
    sleep(40)
    # do a re-index
    `RAILS_ENV=test docker-compose run web rake SOLR_DISABLE_CHECK=1 sunspot:reindex`
    # need more sleep?
    Rake::Task["test:solr_tests"].invoke
    `rake sunspot:solr:stop RAILS_ENV=test`
    # restore "disabled" to true in test for sunspot.yml
    sunspot['test']['disabled'] = true
    File.open("config/sunspot.yml", "w") do |file|
      file.write sunspot.to_yaml
    end
    puts "turning off solr dependence at config/sunspot.yml"
    #puts sunspot.to_yaml
  end

  desc "Run solr-specific tests"
  Rake::TestTask.new(:solr_tests) do |t|
    t.libs << "test"
    t.pattern = 'test/solr/*_test.rb'
    t.verbose = true
  end
end
