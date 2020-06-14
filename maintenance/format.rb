#!/usr/bin/env ruby
require 'find'
require 'open3'

Find.find('.').each do |path|
	next if File.symlink?(path)
	next unless path.end_with?('.dhall')
	puts("[#{path}]")
	original = File.read(path)
	cmd = ['dhall', '--ascii', 'format']
	formatted, status = Open3.capture2(*cmd, stdin_data: original)
	exit(1) unless status.success?
	if formatted != original
		puts(" + #{cmd.join(' ')} --inplace #{path}")
		File.write(path, formatted)
	end
end
              
