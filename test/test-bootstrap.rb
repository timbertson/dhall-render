#!/usr/bin/env ruby
require_relative 'lib/utest'
require 'tmpdir'

load "maintenance/bump"

test("bootstrap") do
  Dir.mktmpdir do |dir|
    puts "temp dir created: #{dir}"
    base = Dir.pwd
    Dir.chdir(dir)
    `cat "#{base}/bootstrap.sh" | bash`
    success = $? == 0
    contents = -> () { File.read("dhall/files.dhall") }
    if success
      puts contents.call
      puts "OK"
    else
      echo "ERROR"
      echo "CURRENT files.dhall:"
      puts contents.call rescue nil
      raise "bootstrap failed"
    end
  end
end
