# rake test:all
namespace :test do
  desc "Run rails and jasmine tests"
  task :all do
    puts "Running Rails tests"
    Rake::Task["test"].execute
    puts "Running jasmine tests headlessly"
    Rake::Task["spec:javascript"].execute
  end
end
