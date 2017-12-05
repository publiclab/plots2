#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Plots2::Application.load_tasks

Rake::Task['test:run'].clear

# rake test:all
namespace :test do

  # run normal rails tests but not solr tests
  #Rake::TestTask.new(:_run) do |t|
  Rake::TestTask.new(:run) do |t|
    t.libs << "test"
       t.test_files = FileList['test/**/*_test.rb'].exclude(
       'test/solr/**/*_test.rb'
    )
  end
  #task :run => ['test:_run']

  desc "Run rails and jasmine tests"
  task :all => :environment do
    require 'coveralls/rake/task'
    Coveralls::RakeTask.new
    if ENV['GENERATE_REPORT'] == 'true'
      require 'ci/reporter/rake/test_unit'
      Rake::Task["ci:setup:testunit"].invoke
    end
    puts "Running Rails tests"
    Rake::Task["test:run"].invoke
    puts "Running Solr-dependent tests"
    Rake::Task["test:solr"].invoke
    puts "Running jasmine tests headlessly"
    Rake::Task["spec:javascript"].invoke
    Rake::Task["coveralls:push"].invoke
  end

  desc "Run rails and jasmine tests"
  task :javascript do
    puts "Running jasmine tests headlessly"
    Rake::Task["spec:javascript"].invoke
  end

  desc "This is where you'd start the embedded Solr engine, and tweak config. Runs solr-specific tests."
  # Solr is assumed running from the container or otherwise available as in sunspot.yml.
  task :solr do
    # overwrite "diabled" in test for sunspot.yml
    require 'yaml'
    sunspot = YAML::load_file "config/sunspot.yml"
    sunspot['test']['disabled'] = false
    File.open("config/sunspot.yml", "w") do |file|
      file.write sunspot.to_yaml
    end
    puts "turning on solr dependence at config/sunspot.yml"
    puts sunspot.to_yaml
    `RAILS_ENV=test rake SOLR_DISABLE_CHECK=1 sunspot:reindex`
    Rake::Task["test:solr_tests"].invoke
    # restore "diabled" to true in test for sunspot.yml
    sunspot['test']['disabled'] = true
    File.open("config/sunspot.yml", "w") do |file|
      file.write sunspot.to_yaml
    end
  end

  desc "Run solr-specific tests"
  Rake::TestTask.new(:solr_tests) do |t|
    t.libs << "test"
    t.pattern = 'test/solr/*_test.rb'
    t.verbose = true
  end

end
