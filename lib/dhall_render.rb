#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'find'
require 'fileutils'
require 'open3'

@default_path = 'dhall/files.dhall'

FORMATTERS = {
	'YAML' => -> (contents) {
		if contents.is_a?(Array)
			require 'psych'
			Psych.dump_stream(*contents)
		else
			contents.to_yaml
		end
	},
	'JSON' => -> (contents) { JSON.pretty_generate(contents) },
	'Raw' => -> (contents) {
		raise "Raw file must be a string, got #{contents.class}" unless contents.is_a? String
		contents
	},
}

INSTALLERS = {
	'Symlink' => -> (current_path, eventual_path, install_path) {
		relative_dirs = install_path.split('/').count - 1
		relative_components = '../' * relative_dirs
		puts(" + ln -sfn #{relative_components}#{eventual_path} #{install_path}")
		FileUtils.symlink(relative_components + eventual_path, install_path, force: true)
	},
	'Write' => -> (current_path, eventual_path, install_path) {
		puts(" + mv #{current_path} #{install_path}")
		FileUtils.rm(install_path, force: true)
		FileUtils.move(current_path, install_path)
		# leave an empty file behind, for tracking "installed files"
		FileUtils.touch(current_path)
	},
	'None' => -> (current_path, eventual_path, install_path) { },
}

def generate_into(generated_tmp:, generated_final:, tree:)
	FileUtils.rm_rf(generated_tmp)
	FileUtils.mkdir_p(generated_tmp)

	generate_file = -> (install_path, doc) do
		puts "#{install_path}:"
		install = doc.fetch('install')
		header = doc['header']
		header_lines = doc.fetch('headerLines', [])
		header_format = doc.fetch('headerFormat', false)

		contents = FORMATTERS.fetch(doc.fetch('format')).call(doc.fetch('contents'))
		executable = doc.fetch('executable')

		if header.nil?
			# compute from header_lines/format
			header = if header_lines.empty?
				nil
			else
				header_body = -> (prefix) {
					header_lines.map {|line| prefix + line }.join("\n")
				}
				case header_format
				when false
					nil
				when String
					header_body.call header_format
				when Hash
					[
						header_format.fetch('prefix'),
						header_body.call(header_format.fetch('linePrefix')),
						header_format.fetch('suffix'),
					].join("\n")
				else
					raise "Unknown headerLines setting: #{header_format.inspect}"
				end
			end
		else
			puts "NOTE: `header` setting on dhall-render file is deprecated and will be removed, use `headerLines` and optionally `headerFormat`"
		end

		unless header.nil?
			# inject header after shebang, if there is one
			prefix = ''
			if contents.slice(0,2) == "#!"
				lines = contents.lines
				prefix = lines[0]
				contents = lines.drop(1).join('')
			end
			contents = "#{prefix}#{header}\n\n#{contents}"
		end
		# ensure it's newline-terminated
		contents = contents.chomp("\n") + "\n"

		tmp_dest = File.join(generated_tmp, install_path)
		final_dest = File.join(generated_final, install_path)
		FileUtils.mkdir_p(File.dirname(tmp_dest))
		FileUtils.mkdir_p(File.dirname(install_path)) unless install == 'None'
		File.write(tmp_dest, contents)
		if executable
			FileUtils.chmod(0755, tmp_dest)
		end
		INSTALLERS.fetch(install).call(tmp_dest, final_dest, install_path)
	end

	generate_file_with_logging = -> (install_path, doc) do
		begin
			generate_file.call(install_path, doc)
		rescue
			puts "Error processing document:\n#{doc.inspect}"
			puts "Document keys: #{doc.keys.inspect}"
			raise
		end
	end

	tree.fetch('files').each_pair do |install_path, doc|
		if doc.is_a?(Array)
			doc.each do |entry|
				generate_file_with_logging.call(File.join(install_path, entry.fetch('path')), entry)
			end
		else
			sub_path = doc['path']
			install_path = File.join(install_path, sub_path) unless sub_path.nil?
			generate_file_with_logging.call(install_path, doc)
		end
	end
end

def overwrite(generated_final:, generated_tmp:)
	FileUtils.rm_rf(generated_final)
	FileUtils.move(generated_tmp, generated_final)
end

def files_recursively_in(path)
	return [] unless File.directory?(path)
	Dir.chdir(path) do
		Find.find('.').reject(&File.method(:directory?))
	end
end

def contains_git_directory?(path)
	return false unless File.directory?(path)
	Dir.chdir(path) do
		not Dir.glob('**/.git').empty?
	end
end


def remove_previously_installed(generated_final:, generated_tmp:)
	unwanted_files = files_recursively_in(generated_final) - files_recursively_in(generated_tmp)
	# puts unwanted_files.inspect
	unless unwanted_files.empty?
		puts "\n*** Removing previously-installed files ..."
		unwanted_files.each do |path|
			puts " + rm #{path}"
			FileUtils.rm_f(path)
		end
	end
end

def process_json(file)
	tree = JSON.load(file)
	# puts tree.inspect
	options = tree.fetch('options', { 'destination' => "generated" })
	generated_final = options.fetch('destination')
	puts "*** Generating files in `#{generated_final}` ..."
	raise "Refusing to overwrite #{generated_final}, it contains a .git folder" if contains_git_directory?(generated_final)

	generated_tmp = generated_final + '.tmp'

	begin
		generate_into(generated_tmp: generated_tmp, generated_final: generated_final, tree: tree)
		remove_previously_installed(generated_tmp: generated_tmp, generated_final: generated_final)

		overwrite(generated_final: generated_final, generated_tmp: generated_tmp)
	ensure
		FileUtils.rm_rf(generated_tmp)
	end
end

DEFAULT_OPTIONS = {
	dhall: true
}

def process(path, options=DEFAULT_OPTIONS)
	if options.fetch(:dhall)
		Open3.popen2('dhall-to-json', '--file', path) do |stdin, stdout, status_thread|
			err = nil
			begin
				process_json(stdout)
			rescue
				raise if status_thread.value.success?
			ensure
				exit(1) unless status_thread.value.success?
			end
		end
	else
		File.open(path, &method(:process_json))
	end
end

def main(args = ARGV)
	require 'optparse'

	options = DEFAULT_OPTIONS.dup
	args = OptionParser.new do |p|
		p.banner = [
			"Usage: dhall-render [OPTIONS] INPUT_FILE",
			"",
			"With no arguments, #{@default_path} is assumed",
			"\n",
		].join("\n")
		p.on('--json', "Assume input is already evaluated to JSON") do ||
			options[:dhall] = false
		end
	end.parse(args)
	args << @default_path if args.empty?

	args.each do |path|
		process(path, options)
	end
end
