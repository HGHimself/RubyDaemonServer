require "./src/Server"
require "./src/Daemon"
require "./src/Scraper"
require "./src/Encryptor"
require "./src/TicTacToe"
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
  puts req.post?('alpha')
  puts req.post?('beta')
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

server.get "/encryption/keygen/" do |req, res|
  e = Encryptor.new
  if !req.get?("p").nil? and !req.get?("q").nil?
    p = req.get?("p").to_i
    q = req.get?("q").to_i
    if e.primality_test(p, 50)
      if e.primality_test(q, 50)
        e.key_generation(p, q)
        html = "<h2>Done!</h2>"
        html += "<h3>Public Key:</h3><p>e = #{e.e} and n = #{e.n}</p>"
        html += "<h3>Private Key:</h3><p>d = #{e.d} and n = #{e.n}</p>"
      else
        html = "<h2>Error!</h2><p>Q must be a prime number.</p>"
      end
    else
      html = "<h2>Error!</h2><p>P must be a prime number.</p>"
    end
  else
    html = "<h2>Error!</h2><p>You must provide an input for P and Q</p>"
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
    html = "<h2>Done!</h2>"
    html += "<h3>Original message:</h3><p>m = #{req.get?("m")}</p>"
    html += "<h3>Encrypted message:</h3><p>c = #{c}</p>"
  else
    html = "<h2>Error!</h2><p>You must provide an input for P, Q, and M</p>"
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
    html = "<h2>Done!</h2>"
    html += "<h3>Encrypted message:</h3><p>c = #{c}</p>"
    html += "<h3>Original message:</h3><p>m = #{t}</p>"
  else
    html = "<h2>Error!</h2><p>You must provide an input for P, Q, and M</p>"
  end
  res.send_string(req.method, html)
end

server.get "/tictactoe/move/" do |req, res|
  if !req.get?("string").nil? and !req.get?("player").nil? and !req.get?("depth").nil?
    t = TicTacToe.new
    string = req.get?("string")
    player = req.get?("player").to_i
    depth = req.get?("depth").to_i
    board = t.parse_board(string)

    board = t.move(board, player, depth)
    # puts "-" * 10
    # t.print_board(board)
    # puts "-" * 10
    res.send_string(req.method, t.stringify_board(board))
  end
end

daemon = Daemon.new daemon_options
daemon.run! do
  while server.status != "Broken" do
    server.listen
  end
end
