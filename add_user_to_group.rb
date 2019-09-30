#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'json'
require 'base64'

group = ARGV[0]
user = ARGV[1]

#$username = 'jason.dopson'
#$password = '1122qqwwAASS!'

$username = ENV["JIRA_CLI_USER"]
$password = Base64.decode64(ENV["JIRA_CLI_PASS"]).chop

def lookup_by_email(email)
  uri = URI.parse("https://reancloud.atlassian.net/rest/api/2/user/search?username=#{email}")
  
  header = {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
  }
  email = {
                     "name": "#{email}"
         }
  
  # Create the HTTP objects
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri, header)
  request.basic_auth($username, $password)
  request.body = email.to_json
  
  # Send the request
  res = https.request(request)
  unless res.code == "200"
          puts "Response #{res.code} #{res.message}"
          return 1
  else
          return JSON.parse(res.body)[0]['key']
  end
end

def add_user_to_group(user,group)

  uri = URI.parse("https://reancloud.atlassian.net/rest/api/2/group/user?groupname=#{group}")
  
  header = {'Content-Type': 'application/json'}
  user = {
                     "name": "#{user}"
         }
  
  # Create the HTTP objects
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.basic_auth($username, $password)
  request.body = user.to_json
  
  # Send the request
  res = https.request(request)
  unless res.code == "201"
	  puts "ERROR: #{res.code} #{res.message}"
	  #return "Response #{res.code} #{res.message}: #{res.body}"
          return 1
  end

end

# Try adding by what was given
puts "Adding #{user} to #{group}"
result = add_user_to_group(user,group)
if (result == 1)
  puts "Couldn't find #{user}...looking up as email"
  # Try to lookup by email
  lookup = lookup_by_email(user)
  if (lookup != 1) 
    #If we found a match, try adding again by key returned from search
    new_result = add_user_to_group(lookup,group)
    unless (new_result == 1)
      puts "* Couldn't add #{lookup} to #{group}: #{new_result}"
    end
  else
    puts "Couldn't find by email!"
  end
end
