if File.exists?(Rails.root.join('config', 'config.yml'))
  APP_CONFIG = YAML.load_file(Rails.root.join('config','config.yml'))[Rails.env]
end
