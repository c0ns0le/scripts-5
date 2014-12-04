#!/usr/bin/env ruby
# Encoding: ISO-8859-1

# Eclipse Test On Save 2014.12.4
# Copyright (c) 2009, 2012, 2013 Renato Silva
# GNU GPLv2 licensed

if ARGV[1].nil?
    usage = "Usage: #{File.basename($PROGRAM_NAME)} <eclipse home> <class> [additional classpath]"
    puts "\n\t#{usage}\n\n"
    exit
end

home = ARGV[0].gsub(/\\/, '/')
test_class = ARGV[1]
additional_classpath = File::PATH_SEPARATOR + ARGV[2] unless ARGV[2].nil?

path = "#{home}/plugins/*"

plugins = Dir[path].find_all do |plugin|
    plugin =~ /org\.(eclipse\.|)(hamcrest\.core|jface_|core\.commands|equinox\.common|swt\..+).*\.jar$/
end

plugins << (Dir[path].find_all do |plugin|
    plugin =~ /org.junit_?4/
end [0] << '/junit.jar')

plugins.map! { |plugin| File::PATH_SEPARATOR + plugin }

classpath = plugins.join.gsub(/\/\//, '/') + additional_classpath.to_s

`java -cp \".#{classpath}\" #{test_class}`
