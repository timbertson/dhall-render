# itty bitty test libby

require 'ostruct'
require 'open3'

def assert_equal(a, b, desc = nil)
	if a != b
		suffix = desc ? " (#{desc})" : ""
		raise "AssertionError, expected: #{b.inspect}, got: #{a.inspect}#{suffix}"
	end
end

def assert_matches(a,b)
	if !b.match?(a)
		raise "AssertionError, expected: #{a.inspect} to match #{b.inspect}"
	end
end

def test(desc)
	puts("# #{desc} ...")
	yield
end

def run(*cmd)
	run?(*cmd).success or raise "Command failed: #{cmd.join(' ')}"
end

def run?(*cmd)
	puts(" + #{cmd.join(' ')}")
	Open3.popen2e(*cmd) do |stdin, out_and_err, wait|
		output = out_and_err.read
		code = wait.value
		OpenStruct.new({ output: output, success: wait.value == 0 })
	end
end
