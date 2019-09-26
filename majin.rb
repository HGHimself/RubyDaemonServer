#!/usr/bin/env ruby

pid_path = 'log/pid.txt'
log_path = 'log/log.txt'
server_exec = './server.rb'

if(File.exist?(pid_path) and !File.directory?(pid_path))
  File.open(pid_path) do |file|
    system("kill -9 #{file.read.chomp}")
    file.close
  end
end

exec("/usr/share/rvm/rubies/ruby-2.6.3/bin/ruby server.rb -d -p #{pid_path} -l #{log_path}")
