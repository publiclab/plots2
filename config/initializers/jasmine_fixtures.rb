# Map fixtures directory for Jasmine suite
if defined?(Jasmine::Jquery::Rails::Engine)
  JasmineFixtureServer = Proc.new do |env|
    Rack::Directory.new('spec/javascripts/fixtures').call(env)
  end
end