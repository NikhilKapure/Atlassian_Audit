#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'json'
require 'base64'

$username = ENV["JIRA_CLI_USER"]
$password = Base64.decode64(ENV["JIRA_CLI_PASS"]).chop

base_url = "https://reancloud.atlassian.net/wiki"


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

mynext = 1

begin
  retries ||= 0
  while mynext != 0
    path = ''
    if mynext != 1
      path = mynext
    else
      path = '/rest/api/content/1212420/child/page'
    end 
    url = base_url + path
    uri = URI.parse("#{url}")
    data = get_method(uri)

    data['results'].each do |page|
      puts "title: #{page['title']}, page: #{page['id']}"
    end

    if data['_links']['next'].nil?
      mynext=0
    else
      mynext=data['_links']['next']
    end
  end
rescue Exception => e
  puts e
  sleep 10
  retry if (retries += 1) < 3
end

