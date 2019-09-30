#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'json'
require 'base64'

$username = ENV["JIRA_CLI_USER"]
$password = Base64.decode64(ENV["JIRA_CLI_PASS"]).chop

pageid = ARGV[0]

uri = URI.parse("https://reancloud.atlassian.net/wiki/rest/api/content/#{pageid}/restriction/byOperation/read/group/global-internal-interns")

header = {'Content-Type': 'application/json'}

# Create the HTTP objects
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
request = Net::HTTP::Put.new(uri.request_uri, header)
request.basic_auth($username, $password)
#request.body = group.to_json

# Send the request
res = https.request(request)
unless res.code == "200"
	puts "Response #{res.code} #{res.message}: #{res.body}"
else
	puts "Updated: #{pageid}"
end
