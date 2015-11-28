require 'bundler'
Bundler.require
Dotenv.load

$LOAD_PATH << File.dirname(__FILE__) + "/lib"
require 'org_dayone'

opts = Slop.parse do |o|
  o.string '-d', '--date',     'date'
  o.string '-m', '--mode',     'mode (sync_org)'
  o.bool   '-v', '--verbose',  'enable verbose mode'
end

case opts[:mode]
when 'sync_org'
  headlines = OrgDayone::Headline.parse(STDIN)
  headlines.each do |h|
    OrgDayone.api.create h.to_markdown, date: opts[:date]
  end
when 'debug'
  debugger
  puts "Time to debug..."
else
  puts opts
end
