#!/usr/bin/env ruby
require_relative 'lib/utest'

load "maintenance/fix"

test("fix imports") do
	[
		{
			src: "https://example.com using ~/headers.dhall sha256:1234",
			fix: "https://example.com using (~/headers.dhall) sha256:1234",
		},
		{
			src: "https://example.com using ./headers.dhall\n    sha256:1234",
			fix: "https://example.com using (./headers.dhall) sha256:1234",
		},
	].each do |test_case|
		assert_equal(fix_imports_in_text(test_case.fetch(:src)), test_case.fetch(:fix))
	end
end
