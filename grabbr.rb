#! /usr/bin/env ruby

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

  options[:url] = nil
  opts.on( '-s', '--set_url http://...', 'URL to set you want to grab.' ) do |url|
    options[:url] = url
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

begin
  client = Soundcloud.new({
    :client_id      => "9cff615532437339d2212bd52621cada",
    :client_secret  => "6de206d478aca32cdd83494966516d89",
    :username       => user,
    :password       => token.strip,
  })

  # print logged in username
  puts ""
  puts "Logged in as: #{client.get('/me').username}"
  puts ""

  if options[:url].nil?
    $stderr.print "Enter the set you wish to get: "
    url = gets.chomp
  else
    url = options[:url]
  end

  # http://developers.soundcloud.com/docs/api/reference#resolve
  playlist_data = client.get('/resolve', :url => url)

  puts "Title: #{playlist_data.title}"

  puts "\nDescription:\n #{playlist_data.description}"

  pbar = ProgressBar.new("Tracks", playlist_data.tracks.count)
  playlist_data.tracks.each do |track|

    filename = "#{track.permalink}.mp3"
    File.open(filename, "w") do |file|
      file << client.get(track.download_url)
    end

    pbar.inc
  end
rescue SoundCloud::ResponseError => e
  puts e.message
end
