if File.exists?(Rails.root.join('config', 's3.yml'))
APP_CONFIG = YAML.load_file(Rails.root.join('config','config.yml'))[RAILS_ENV]
end
