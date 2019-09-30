#!/usr/bin/ruby

require 'roo'
require 'net/http'
require 'uri'
require 'json'
require 'base64'

$username = ENV["JIRA_CLI_USER"]
$password = Base64.decode64(ENV["JIRA_CLI_PASS"]).chop

def add_group(group)
  uri = URI.parse("https://reancloud.atlassian.net/rest/api/2/group")
  header = {'Content-Type': 'application/json'}
  group = { "name": "#{group}" }
  # Create the HTTP objects
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.basic_auth($username, $password)
  request.body = group.to_json
  
  # Send the request
  res = https.request(request)
  unless res.code == "201"
          #puts "Response #{res.code} #{res.message}: #{res.body}"
          return res.body
  end
  return 0
end

def add_user(group, user)
  uri = URI.parse("https://reancloud.atlassian.net/rest/api/2/group/user?groupname=#{group}")
  header = {'Content-Type': 'application/json'}
  user = { "name": "#{user}" }
  
  # Create the HTTP objects
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.basic_auth($username, $password)
  request.body = user.to_json
  
  # Send the request
  res = https.request(request)
  unless res.code == "201"
          #puts "Response #{res.code} #{res.message}: #{res.body}"
          return res.body
  end
  return 0
end

xlsx = Roo::Spreadsheet.open('./global-groups.xlsx')

xlsx.each_with_pagename do |name, sheet|
  sheet.each do |row|
    puts "Group: #{row[0]}"

    next if row[0].nil? || row[0].empty?
    next if row[1].nil? || row[1].empty?

    group = add_group(row[0])
    if (group != 0)
      puts "X: #{row[0]}: #{group}"
    else
      puts "."
    end
    
    row[1].split("\n").each do |member|
      member = member.strip

      if (member =~ /.*\@.*\..*/) 
        username,domain = member.split('@')
        member = username
      end

      user_status = add_user(row[0],member)

      if (user_status != 0)
        puts "X: #{member}: #{user_status}"
      else 
        puts "."
      end

    end
  end
end
