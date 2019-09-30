#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'json'
require 'pp'
require 'base64'

$username = ENV["JIRA_CLI_USER"]
$password = Base64.decode64(ENV["JIRA_CLI_PASS"]).chop

group = ARGV[0]

#uri = URI.parse("https://reancloud.atlassian.net/rest/api/2/user/search?username=#{user}")
group_uri = URI.parse("https://reancloud.atlassian.net/rest/api/2/groupuserpicker?query=#{group}&maxResults=1000")

user = {
                   "name": "#{user}"
       }

def get_method(uri)
  header = {
	'Content-Type': 'application/json',
	'Accept': 'application/json'
  }
  # Create the HTTP objects
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri, header)
  request.basic_auth($username, $password)
  #request.body = user.to_json
    
  # Send the request
  res = https.request(request)
  unless res.code == "200"
	puts "Response #{res.code} #{res.message}: #{res.body}"
  else
    data = JSON.parse(res.body)
    return  data
  end
end

group_data = get_method(group_uri)
group_data['groups']['groups'].each do |group|
#    puts group['name']
  user_array = Array.new
  is_last = false
  start_at = 0
  total = 0

  begin
    retries ||= 0
    while is_last == false
      user_uri = URI.parse("https://reancloud.atlassian.net/rest/api/2/group/member?groupname=#{group['name']}&startAt=#{start_at}")
      user_data = get_method(user_uri)
      user_data['values'].each do |user|
        puts "#{group['name']},#{user['displayName']},#{user['emailAddress']},#{user['key']}"
      end
      start_at += user_data['maxResults']
      is_last=user_data['isLast']
    end
  rescue Exception => e
    puts e
    sleep 10
    retry if (retries += 1) < 3
  end
end

#group_data = get_method(group_uri)
#group_data['groups']['groups'].each do |group|
#    puts group['name']
#end
