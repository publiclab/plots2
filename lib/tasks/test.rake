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

  desc "This is where you'd start the embedded Solr engine, and tweak config. Runs solr-specific tests."
  # Solr is assumed running from the container or otherwise available as in sunspot.yml.
  task :solr do
    `RAILS_ENV=test rake SOLR_DISABLE_CHECK=1 sunspot:reindex`
    Rake::Task["test:solr_tests"].invoke
  end

  desc "Run solr-specific tests"
  Rake::TestTask.new(:solr_tests) do |t|
    t.libs << "test"
    t.pattern = 'test/solr/*_test.rb'
    t.verbose = true
  end
end
