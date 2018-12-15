#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/testtask'

Plots2::Application.load_tasks

Rake::Task['test:run'].clear

namespace :test do

  Rake::TestTask.new(:run) do |t|
    t.libs << "test"
    t.test_files = FileList['test/**/*_test.rb']
  end

  desc "Run rails and teaspoon tests"
  task :all => :environment do
    require 'coveralls/rake/task'
    Coveralls::RakeTask.new
    if ENV['GENERATE_REPORT'] == 'true'
      require 'ci/reporter/rake/test_unit'
      Rake::Task["ci:setup:testunit"].execute
    end
    puts "Running teaspoon tests headlessly"
    Rake::Task["teaspoon"].execute
    Rake::Task['test:run'].execute
    Rake::Task["coveralls:push"].execute
  end
end
