# rake cloud9 username=foo
task :cloud9 do
  username = ENV['username']
  infile = "config/database.yml.cloud9"
  outfile = "config/database.yml"

  File.open(outfile, 'w') do |out|
    out << File.open(infile).read.gsub(/<username>/, username)
  end  
end
