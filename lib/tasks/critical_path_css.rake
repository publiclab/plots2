require 'critical-path-css-rails'

namespace :critical_path_css do
  desc 'Generate critical CSS for the routes defined'
  task generate: :environment do
    CriticalPathCss.generate_all
  end

  desc 'Clear all critical CSS from the cache'
  task clear_all: :environment do
    # Use the following for Redis cache implmentations
    CriticalPathCss.clear_matched('*')
    # Some other cache implementations may require the following syntax instead
    # CriticalPathCss.clear_matched(/.*/)
  end
end

Rake::Task['assets:precompile'].enhance { Rake::Task['critical_path_css:generate'].invoke }
