#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'json'
require 'base64'

$username = ENV["JIRA_CLI_USER"]
$password = Base64.decode64(ENV["JIRA_CLI_PASS"]).chop

space = ARGV[0]

def get_space_keys()

  uri = URI.parse("https://reancloud.atlassian.net/wiki/rest/api/space?limit=500")

  header = {'Content-Type': 'application/json'}
  #group = {'space': 'CUS'}

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
          #puts "Received space perms for #{space}"
          return JSON.parse(res.body)
  end
end

def get_space(space)

  uri = URI.parse("https://reancloud.atlassian.net/wiki/rest/api/space/#{space}?expand=permissions")

  header = {'Content-Type': 'application/json'}
  # group = {'space': 'CUS'}

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
          #puts "Received space perms for #{space}"
	  return JSON.parse(res.body)
  end
end

hash = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }

spaces = get_space_keys()

spaces['results'].each do |space|
  #puts space['key']
  key = space['key']
  #key = 'AM'

  data = get_space(key)

  group_users = Array.new
  perms = Hash.new

  data['permissions'].each do |a|
    #puts "Test[A]: #{a}"
    acct = ""
    o_name = a['operation']['operation']
    o_type = a['operation']['targetType']
    user_perms = Hash.new
    Array(a['subjects']).each do |b|
      case b[0]
        when "user"
          acct = b[1]['results'][0]['username']
        when "group"
          acct = b[1]['results'][0]['name']
        else
          #puts "Found junk"
      end
    end
    #group_users.push(acct)
    #puts "#{key},#{acct},#{o_name},#{o_type}"
    hash[key][acct][o_type][o_name]="X"
  #  perms[acct][o_name].push(o_type)
  end
end

puts "key,user,space_read,space_admin,space_export,space_restrictions,page_create,page_delete,blog_create,blog_delete,attachment_create,attachment_delete,comments_create,comments_delete"
hash.each do |key, array|
  #puts "#{key}---------"
  array.each do |user, perms|
    #puts "#{user}---------"
    #puts "#{perms}----------"
    puts "#{key},#{user},#{perms['space']['read']},#{perms['space']['administer']},#{perms['space']['export']},#{perms['space']['restrictions']},#{perms['page']['create']},#{perms['page']['delete']},#{perms['blogpost']['create']},#{perms['blogpost']['delete']},#{perms['attachment']['create']},#{perms['attachment']['delete']},#{perms['comment']['create']},#{perms['comment']['delete']}"
  end
end
