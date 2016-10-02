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
    puts `rake sunspot:solr:start RAILS_ENV=test`
    puts `rake test TEST=test/solr/searches_controller_test.rb`
    puts `rake sunspot:solr:stop RAILS_ENV=test`
  end
end
