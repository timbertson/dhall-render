#!/usr/bin/env ruby
require 'yaml'
require_relative 'lib/utest'
require_relative '../lib/dhall_render.rb'
require 'tmpdir'

Dir.mktmpdir do |dir|
  puts "temp dir created: #{dir}"
  base = Dir.pwd

  # first test the edge cases included in examples:
  main(['examples/files.dhall'])

  test('fileList') do
    [1,2,3].each do |age|
      assert_equal(YAML.load_file("examples/files/list/#{age}.yml"), {'name' => 'youngling', 'age' => age})
    end
  end

  test('yaml-list') do
    require 'psych'
    assert_equal(
      Psych.load_stream(File.read('examples/files/config-list.yml')),
      [
        { 'name' => "tim", 'age' => 50 },
        { 'name' => "fred", 'age' => 50 }
      ])
  end

  # Then the full test suite, with less interesting edge cases
  # (and we don't commit the results)
  Dir.chdir(dir)
  Dir.mkdir('dhall')
  dhall_file = File.read(File.join(base, 'test/files.dhall'))
  File.write('dhall/files.dhall', dhall_file.sub('../package.dhall', File.join(base, 'package.dhall')))
  main([])

  test("destination") do
    assert_equal(File.symlink?('hello'), true)
    assert_equal(File.readlink('hello'), 'out/hello')
    assert_equal(File.readlink('nested/hello'), '../out/nested/hello')
    assert_equal(File.read('out/hello'), "Hello!\n")
  end

  test("executable") do
    assert_equal(File.executable?('hello.sh'), true)
  end

  test("shebang + header") do
    assert_equal(File.read('hello-shebang.sh'), [
      '#!/usr/bin/env bash',
      "# (header)",
      "",
      'echo hello',
      ""
    ].join("\n"))
  end

  test("install") do
    assert_equal(File.symlink?('no-symlink'), false)
  end

  test("headerFormat") do
    assert_equal(File.read('hello.html'), "<!--\n  header1\n  header2\n-->\n\n<h1>Hello</h1>\n")
  end
end
