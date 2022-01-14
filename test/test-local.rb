#!/usr/bin/env ruby
require_relative 'lib/utest'

load "maintenance/fix"

[
	{
		desc: "local",
		env: 'test/local/local.dhall',
		output: "number: 1"
	},
	{
		desc: "empty env",
		env: 'test/local/local-empty.dhall',
		output: "1"
	},
	{
		desc: "missing",
		env: 'test/local/local-missing.dhall',
		success: false,
		output: /importing env:DHALL_SHOW failed; evaluate it directly for the underlying error/
	},

	{
		desc: "type error",
		env: 'test/local/local-type-err.dhall',
		success: false,
		output: /Error.* Wrong type of function argument.*mapKey = "DHALL_SHOW", mapValue = "just-a-string/m
	},
].each do |test_case|
	local_args = test_case.fetch(:args, [])
	env_file = test_case.fetch(:env)
	file = test_case.fetch(:file, "test/local/test.dhall")
	local_args = local_args + ['-e', env_file]
	test("#{test_case[:desc]} (#{local_args})") do
		result = run?(
			'./maintenance/local', *local_args,
			'dhall', 'text', '--file', file
		)
		# puts result.output
		if result.success
			result.output = result.output.gsub(/^\[ .*\n/, '')
		end
		assert_equal(result.success, test_case.fetch(:success, true), "process with output:\n#{result.output}")
		expected_output = test_case.fetch(:output)
		if expected_output.is_a?(Regexp)
			assert_matches(result.output, expected_output)
		else
			assert_equal(result.output, expected_output)
		end
	end
end
