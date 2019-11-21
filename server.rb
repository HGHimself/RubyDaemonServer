#!/usr/bin/env ruby

require "./src/Daemon"
require "./src/Encryptor"
require "./src/Measure"
# require "./src/Scraper"
require "./src/Server"
require "./src/Templator"
# require "./src/TicTacToe"
require 'optparse'
# require 'colorize'

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
  key: "/etc/letsencrypt/live/kingtech.dev/privkey.pem",
  crt: "/etc/letsencrypt/live/kingtech.dev/fullchain.pem",
  host: '0.0.0.0',
  port: 443
}

server = Server.new server_options

server.get "/" do |req, res|
  res.send_file(req.method, req.abs_path)
end

server.get "/test.html" do |req, res|
  res.send_file(req.method, req.abs_path)
end

server.post "/test.html" do |req, res|
  puts req.post?('alpha')
  puts req.post?('beta')
  res.send_file(req.method, req.abs_path)
end
#
# server.get %r"\/[a-zA-Z1-9\-\/_]*\.majin" do |req, res|
#   t.translate(req.abs_path)
#   res.send_string(req.method, t.string)
# end

#
# server.post "/" do |req, res|
#   data = JSON.parse(req.body)
#   puts data['student']
#   res.send_file(req.method, req.abs_path)
# end
#
# server.get "/scraper/" do |req, res|
#   res.send_file(req.method, req.abs_path)
# end
#
# server.post "/scraper/" do |req, res|
#   res.send_string(req.method, req.body)
# end
#
# server.get "/scraper/search/" do |req, res|
#   scraper = Scraper.new
#   html = scraper.doWork(req.get?("query"))
#   res.send_string(req.method, html)
# end
#

server.get "/encryption/keygen/" do |req, res|
  e = Encryptor.new
  if !req.get?("p").nil? and !req.get?("q").nil?
    p = req.get?("p").to_i
    q = req.get?("q").to_i
    if e.primality_test(p, 50)
      if e.primality_test(q, 50)
        e.key_generation(p, q)
        html = "<h5>Done!</h5>"
        html += "<h6>Public Key: e = #{e.e} and n = #{e.n}</h6>"
        html += "<h6>Private Key: d = #{e.d} and n = #{e.n}</h6>"
      else
        html = "<h5>Error! Q must be a prime number.</h5>"
      end
    else
      html = "<h5>Error! P must be a prime number.</h5>"
    end
  else
    html = "<h5>Error! You must provide an input for P and Q</h5>"
  end
  res.send_string(req.method, html)
end

server.get "/encryption/encrypt/" do |req, res|
  e = Encryptor.new
  if !req.get?("p").nil? and !req.get?("q").nil? and !req.get?("m").nil?
    p = req.get?("p").to_i
    q = req.get?("q").to_i
    m = req.get?("m").to_i
    e.key_generation(p, q)
    c = e.encrypt(m)
    html = "<h5>Done!</h5>"
    html += "<h6>Original message: m = #{req.get?("m")}</h6>"
    html += "<h6>Encrypted message: c = #{c}</h6>"
  else
    html = "<h5>Error! You must provide an input for P, Q, and M</h5>"
  end
  res.send_string(req.method, html)
end

server.get "/encryption/decrypt/" do |req, res|
  e = Encryptor.new
  if !req.get?("p").nil? and !req.get?("q").nil? and !req.get?("m").nil?
    p = req.get?("p").to_i
    q = req.get?("q").to_i
    m = req.get?("m").to_i
    e.key_generation(p, q)
    c = e.encrypt(m)
    t = e.decrypt(c)
    html = "<h5>Done!</h5>"
    html += "<h6>Encrypted message: c = #{c}</h6>"
    html += "<h6>Original message: m = #{t}</h6>"
  else
    html = "<h5>Error! You must provide an input for P, Q, and M</h5>"
  end
  res.send_string(req.method, html)
end
#
# server.get "/tictactoe/move/" do |req, res|
#   if !req.get?("string").nil? and !req.get?("player").nil? and !req.get?("depth").nil?
#     t = TicTacToe.new
#     string = req.get?("string")
#     player = req.get?("player").to_i
#     depth = req.get?("depth").to_i
#     board = t.parse_board(string)
#
#     board = t.move(board, player, depth)
#     # puts "-" * 10
#     # t.print_board(board)
#     # puts "-" * 10
#     res.send_string(req.method, t.stringify_board(board))
#   else
#     res.error()
#   end
# end
#
server.get "/performance/data.json" do |req, res|
  param = req.get?("param")
  if(!param.nil?)
    m = Measure.new
    log_file = '/home/hg/ruby/RubyDaemonServer/log/log.txt'
    res.send_string(req.method, m.measure_server_performace(log_file, param.to_i))
  else
    res.error()
  end
end

server.get %r"\/[a-zA-Z1-9\-\/_]*[\.]?[a-z]*" do |req, res|
  res.send_file(req.method, req.abs_path)
end

daemon = Daemon.new daemon_options
daemon.run! do
  while server.status != "Broken" do
    server.listen
  end
end
