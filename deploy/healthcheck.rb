#!/usr/bin/env ruby

# Check Health of each service
######################################
require 'net/http'
require 'optparse'
require 'json'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage healthcheck.rb -h [host] -t [timeout]"
    opts.on("-h", "--hostname localhost", "Specify hostname") do |v|
        options[:hostname] = v
    end
    opts.on("-t", "--timeout 60", OptionParser::DecimalInteger, "Specify timeout in seconds") do |v|
        options[:timeout] = v
    end
    opts.on("-d", "--delay 60", OptionParser::DecimalInteger, "Specify seconds to delay") do |v|
        options[:delay] = v
    end
    opts.on("-s", "--services X,Y", "Specify services to check") do |v|
        options[:services] = v
    end
end.parse!

unless options.key?(:services)
    puts "no services specified"
    exit!
end

if options.key?(:delay)
    puts "Sleeping for #{options[:delay]}s..."
    sleep options[:delay]
end

health = {}
services = options[:services].split(',')
services.each do |service|
    begin
        url = service
        if options.key?(:hostname)
            url = "#{options[:hostname]}/#{url}"
        end
        resp = Net::HTTP.get_response(url, '/health')
    rescue
        health[service] = "err"
    else
        json = JSON.parse(resp.body)['health']
        json.each do |item|
            health[item["service"]] = item["status"]
        end
    end
end

puts JSON.pretty_generate(health)
unless health.all? {|service, status| status == "OK" }
    exit(1)
end
