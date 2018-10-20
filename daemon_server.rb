require 'optparse'
require './server.2.rb'

options        = {}
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
op.on("-d", "--daemonize",   daemonize_help) {         options[:daemonize] = true  }
op.on("-p", "--pid PIDFILE", pidfile_help)   { |value| options[:pidfile]   = value }
op.on("-l", "--log LOGFILE", logfile_help)   { |value| options[:logfile]   = value }
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


Emerald::Server.new(options).run!
