require 'bundler'
Bundler.require
Dotenv.load

$LOAD_PATH << File.dirname(__FILE__) + "/lib"
require 'org_dayone'

opts = Slop.parse do |o|
  o.string '-m', '--mode',     'mode (sync_org)'
  o.string '-o', '--org_file'
  o.bool   '-v', '--verbose',  'enable verbose mode'
end

case opts[:mode]
when 'sync_org'
  # TODO
when 'debug'
  debugger
  puts "Time to debug..."
else
  puts opts
end
