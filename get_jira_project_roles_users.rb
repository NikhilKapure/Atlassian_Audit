#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'json'
require 'pp'
require 'base64'

$username = ENV["JIRA_CLI_USER"]
$password = Base64.decode64(ENV["JIRA_CLI_PASS"]).chop

group = ARGV[0]

uri = URI.parse("https://reancloud.atlassian.net/rest/api/2/project")

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

puts "Project Key,Project Name,Role,Member"
project_data = get_method(uri)
project_data.each do |project|
  #puts "Project: #{project['id']}, #{project['key']}, #{project['name']}"
  role_data = get_method(URI.parse("https://reancloud.atlassian.net/rest/api/2/project/#{project['key']}/role"))
  role_data.each do |role|
    #puts "	Role: #{role}"
    member_data = get_method(URI.parse("#{role[1]}"))
    member_data['actors'].each do |member|
      next if role[0] == "atlassian-addons-project-access"
      puts "#{project['key']},#{project['name']},#{role[0]},#{member['displayName']}"
    end
  end
end
