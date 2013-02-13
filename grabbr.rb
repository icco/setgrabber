require 'rubygems'
require 'bundler'

Bundler.require

require 'optparse'

# Argument parsing
options = {}
OptionParser.new do |opts|

  options[:user] = nil
  opts.on( '-u', '--user username', 'Which user to log in as.' ) do |user|
    options[:user] = user
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end.parse!


if options[:user].nil?
  $stderr.print "Enter your soundcloud username: "
  user = gets.chomp
else
  user = options[:user]
end

$stderr.print "Enter your soundcloud password: "
token = STDIN.noecho(&:gets)

$stderr.puts ""

client = Soundcloud.new({
  :client_id      => "9cff615532437339d2212bd52621cada",
  :client_secret  => "6de206d478aca32cdd83494966516d89",
  :username       => user,
  :password       => token.strip,
})

# print logged in username
puts client.get('/me').username

puts client.get('/playlists/405726.json')
