all: fix test

fix:
	maintenance/bootstrap.rb
	maintenance/update
	maintenance/fix

test:
	test/test-fix.rb
	test/test-bump.rb
	test/test-render.rb
	test/test-bootstrap.rb

freeze:
	dhall --ascii freeze --inplace self-install.dhall

.PHONY: all fix test

