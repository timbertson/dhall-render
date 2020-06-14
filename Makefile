all: bin/dhall-render test

bin/dhall-render:
	maintenance/format.rb
	maintenance/bootstrap.rb
	maintenance/update

test:
	bin/dhall-render examples/files.dhall

freeze:
	dhall --ascii freeze --inplace self-install.dhall

.PHONY: all bin/dhall-render test

