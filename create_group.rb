#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'json'
require 'base64'

$username = ENV["JIRA_CLI_USER"]
$password = Base64.decode64(ENV["JIRA_CLI_PASS"]).chop

uri = URI.parse("https://reancloud.atlassian.net/rest/api/2/group")
group = ARGV[0]

header = {'Content-Type': 'application/json'}
group = {
                   "name": "#{group}"
       }

# Create the HTTP objects
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
request = Net::HTTP::Post.new(uri.request_uri, header)
request.basic_auth($username, $password)
request.body = group.to_json

# Send the request
res = https.request(request)
unless res.code == "201"
	puts "Response #{res.code} #{res.message}: #{res.body}"
else
	puts "Added: #{group}"
end
