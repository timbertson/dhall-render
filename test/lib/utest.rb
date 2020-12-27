# itty bitty test libby
def assert_equal(a,b)
	if a != b
		raise "AssertionError, expected: #{b.inspect}, got: #{a.inspect}"
	end
end

def test(desc)
	puts("# #{desc} ...")
	yield
end
