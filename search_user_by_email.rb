#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'json'
require 'pp'
require 'base64'

$username = ENV["JIRA_CLI_USER"]
$password = Base64.decode64(ENV["JIRA_CLI_PASS"]).chop

user = ARGV[0]

uri = URI.parse("https://reancloud.atlassian.net/rest/api/2/user/search?username=#{user}")

header = {
	'Content-Type': 'application/json',
	'Accept': 'application/json'
}
user = {
                   "name": "#{user}"
       }

# Create the HTTP objects
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
request = Net::HTTP::Get.new(uri.request_uri, header)
request.basic_auth($username, $password)
request.body = user.to_json

# Send the request
res = https.request(request)
unless res.code == "200"
	puts "Response #{res.code} #{res.message}: #{res.body}"
else
	jj JSON[res.body]
end
