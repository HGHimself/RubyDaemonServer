require "./src/Server"
require "./src/Daemon"
require "./src/Scraper"
require 'optparse'
require 'colorize'


String.disable_colorization false   # enable colorization

daemon_options = {}
version        = "1.0.0"
daemonize_help = "run daemonized in the background (default: false)"
pidfile_help   = "the pid filename"
logfile_help   = "the log filename"
include_help   = "an additional $LOAD_PATH"
debug_help     = "set $DEBUG to true"
warn_help      = "enable warnings"

op = OptionParser.new
op.banner =  "Daemonize a ruby Emerald server."
op.separator ""
op.separator "Usage: daemon_server [options]"
op.separator ""

op.separator "Process options:"
op.on("-d", "--daemonize",   daemonize_help) {         daemon_options[:daemonize] = true  }
op.on("-p", "--pid PIDFILE", pidfile_help)   { |value| daemon_options[:pidfile]   = value }
op.on("-l", "--log LOGFILE", logfile_help)   { |value| daemon_options[:logfile]   = value }
op.separator ""

op.separator "Ruby options:"
op.on("-I", "--include PATH", include_help) { |value| $LOAD_PATH.unshift(*value.split(":").map{|v| File.expand_path(v)}) }
op.on(      "--debug",        debug_help)   { $DEBUG = true }
op.on(      "--warn",         warn_help)    { $-w = true    }
op.separator ""

op.separator "Common options:"
op.on("-h", "--help")    { puts op.to_s; exit }
op.on("-v", "--version") { puts version; exit }
op.separator ""
op.separator "Query running processes: 'ps -ef | grep ruby'"
op.separator ""

op.parse!(ARGV)


server_options = {
  timer: true,
  ssl: true,
  crt: "/home/hg/nodeStuff/encryption/hgking.xyz.crt",
  key: "/home/hg/nodeStuff/encryption/server.key",
  host: '0.0.0.0',
  port: 12345
}

server = Server.new server_options

server.get "/" do |req, res|
  res.send_file(req.method, req.abs_path)
end

server.get "/test.html" do |req, res|
  res.send_file(req.method, req.abs_path)
end

server.post "/test.html" do |req, res|
  res.send_file(req.method, req.abs_path)
end

server.get %r"\/[a-zA-Z1-9\-\/_]*[\.]?[a-z]*" do |req, res|
  res.send_file(req.method, req.abs_path)
end

server.post "/" do |req, res|
  data = JSON.parse(req.body)
  puts data['student']
  res.send_file(req.method, req.abs_path)
end

server.get "/scraper/" do |req, res|
  res.send_file(req.method, req.abs_path)
end

server.post "/scraper/" do |req, res|
  res.send_string(req.method, req.body)
end

server.get "/scraper/search/" do |req, res|
  scraper = Scraper.new
  html = scraper.doWork(req.get?("query"))
  res.send_string(req.method, html)
end

daemon = Daemon.new daemon_options
daemon.run! do
  while server.status != "Broken" do
    server.listen
  end
end
