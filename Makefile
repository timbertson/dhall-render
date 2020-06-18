all: bin/dhall-render test

bin/dhall-render:
	maintenance/fix
	maintenance/bootstrap.rb
	maintenance/update

test:
	bin/dhall-render examples/files.dhall
	echo '(./examples/bootstrap.dhall).dhall-render.contents' | dhall text | ruby -c

freeze:
	dhall --ascii freeze --inplace self-install.dhall

.PHONY: all bin/dhall-render test

