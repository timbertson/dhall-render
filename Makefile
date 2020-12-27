all: bin/dhall-render test

bin/dhall-render:
	maintenance/bootstrap.rb
	maintenance/update
	maintenance/fix

test:
	bin/dhall-render examples/files.dhall
	maintenance/test-bump.rb
	maintenance/test-bootstrap.sh

freeze:
	dhall --ascii freeze --inplace self-install.dhall

.PHONY: all bin/dhall-render test

