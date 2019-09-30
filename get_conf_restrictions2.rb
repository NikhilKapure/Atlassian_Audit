#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'json'
require 'base64'

$username = ENV["JIRA_CLI_USER"]
$password = Base64.decode64(ENV["JIRA_CLI_PASS"]).chop

#uri = URI.parse("https://reancloud.atlassian.net/wiki/rest/api/content/91981497/restriction/byOperation/read/group/global-internal-interns")
#uri = URI.parse("https://reancloud.atlassian.net/wiki/rest/api/content/1212420/child/page")
uri = URI.parse("https://reancloud.atlassian.net/wiki/rest/api/content/178126985/child/page")

header = {'Content-Type': 'application/json'}

# Create the HTTP objects
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
request = Net::HTTP::Get.new(uri.request_uri, header)
request.basic_auth($username, $password)
#request.body = group.to_json

# Send the request
res = https.request(request)
unless res.code == "200"
	puts "Response #{res.code} #{res.message}: #{res.body}"
else
	json = JSON.parse(res.body)
        #jj json
        json['results'].each do |page|
          puts "title: #{page['title']}, page: #{page['id']}"
        end
end
