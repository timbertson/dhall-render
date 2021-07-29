#!/usr/bin/env ruby
require_relative 'lib/utest'

load "maintenance/fix"

[
	{
		desc: "local",
		file: 'test/local/present.dhall',
		output: "number: 1"
	},
	{
		desc: "scope selected",
		args: ['-s', 'show'],
		file: 'test/local/present-scoped.dhall',
		output: "number: 1"
	},
	{
		desc: "scope not selected",
		file: 'test/local/present-scoped.dhall',
		output: "1"
	},

	{
		desc: "missing: lax",
		file: 'test/local/missing.dhall',
		output: "1"
	},

	{
		desc: "missing: scope not selected",
		file: 'test/local/missing-scoped.dhall',
		output: "1"
	},

	{
		desc: "missing: semi-scope not selected",
		file: 'test/local/missing-semi-scoped.dhall',
		output: "1"
	},

	{
		desc: "missing: scope selected",
		args: ['-s', 'show'],
		file: 'test/local/missing-scoped.dhall',
		success: false,
		output: /local "import failed"/
	},

	{
		desc: "missing: semi-scope selected",
		args: ['-s', 'show'],
		file: 'test/local/missing-semi-scoped.dhall',
		success: false,
		output: /local "import failed"/
	},
].each do |test_case|
	local_args = test_case.fetch(:args, [])
	file = test_case.fetch(:file)
	full_args = local_args + [file]
	test("#{test_case[:desc]} (#{full_args})") do
		result = run?(
			'./maintenance/local', *local_args,
			'dhall', 'text', '--file', file
		)
		assert_equal(result.success, test_case.fetch(:success, true), "process with output:\n#{result.output}")
		expected_output = test_case.fetch(:output)
		if expected_output.is_a?(Regexp)
			assert_matches(result.output, expected_output)
		else
			assert_equal(result.output, expected_output)
		end
	end
end
