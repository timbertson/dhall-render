#!/usr/bin/env ruby

load "maintenance/bump"

def assert_equal(a,b)
	if a != b
		raise "AssertionError, expected: #{b.inspect}, got: #{a.inspect}"
	end
end

def test(desc)
	puts("# #{desc} ...")
	yield
end

class ExecStatus
	def initialize(success)
		@success = success
	end

	def success?
		@success
	end
end

class FakeExec
	def initialize(expected: nil, stdout:)
		@stdout = stdout
		@expected = expected
	end

	def capture2(env, *args)
		unless @expected.nil?
			assert_equal(args, @expected)
		end
		return [@stdout, ExecStatus.new(true)]
	end
end

ENV.delete('GITHUB_TOKEN')
test("resolve ref") do
	exec = FakeExec.new(
		expected: ['git', 'ls-remote', 'https://github.com/timbertson/test', 'ref1'],
		stdout: "e17cf7a168ce70ec0371410c2262ee1e72ef72f9\trefs/heads/master\n")
	spec = Spec.new('timbertson/test', ExplicitRef.new('ref1'), exec)
	assert_equal(spec.resolved, 'e17cf7a168ce70ec0371410c2262ee1e72ef72f9')
end

test("resolve HEAD") do
	exec = FakeExec.new(
		expected: ['git', 'ls-remote', 'https://github.com/timbertson/test', 'HEAD'],
		stdout: "e17cf7a168ce70ec0371410c2262ee1e72ef72f9\tHEAD\n")
	spec = Spec.new('timbertson/test', ExplicitRef.new('HEAD'), exec)
	assert_equal(spec.resolved, 'e17cf7a168ce70ec0371410c2262ee1e72ef72f9')
end

test("resolve the latest tag") do
	exec = FakeExec.new(
		expected: ['git', 'ls-remote', 'https://github.com/timbertson/test'],
		stdout: [
			"e17cf7a168ce70ec0371410c2262ee1e72ef72f9\tHEAD",
			"e17cf7a168ce70ec0371410c2262ee1e72ef72f9\trefs/heads/main",
			"e17cf7a168ce70ec0371410c2262ee1e72ef72f9\trefs/tags/v1.0.0",
			"e17cf7a168ce70ec0371410c2262ee1e72ef72f9\trefs/tags/v1.20.0",
			"e17cf7a168ce70ec0371410c2262ee1e72ef72f9\trefs/tags/v1.2.0",
		].join("\n"))
	spec = Spec.new('timbertson/test', LatestTagRef.new, exec)
	assert_equal(spec.resolved, 'v1.20.0')
end

test("guess specs") do
	specs = guess_specs({specs: []},"
		https://raw.githubusercontent.com/user1/repo1/tag1/
		https://raw.githubusercontent.com/user1/repo2/tag2/
		https://raw.githubusercontent.com/user2/repo3/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/
	")
	assert_equal(specs, [
		Spec.new('user1/repo1', LatestTagRef.new),
		Spec.new('user1/repo2', LatestTagRef.new),
		Spec.new('user2/repo3', ExplicitRef.new('HEAD')),
	])
end

test("parse spec") do
	assert_equal(Spec.parse('foo/bar'), Spec.new('foo/bar', LatestTagRef.new))
	assert_equal(Spec.parse('foo/bar:'), Spec.new('foo/bar', LatestTagRef.new))
	assert_equal(Spec.parse('foo/bar:baz'), Spec.new('foo/bar', ExplicitRef.new('baz')))
end
