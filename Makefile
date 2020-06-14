all: bin/dhall-files test

bin/dhall-files:
	maintenance/format.rb
	maintenance/bootstrap.rb
	maintenance/update

test:
	bin/dhall-files examples/files.dhall

freeze:
	dhall --ascii freeze --inplace self-install.dhall

.PHONY: all bin/dhall-files test

